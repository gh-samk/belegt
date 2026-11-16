import { cp, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import postgres from "postgres";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { MIGRATIONEN, migrieren } from "../db/migrieren.ts";
import { testAdminUrl, testDatenbankUrl } from "../test-db.ts";

describe.skipIf(!testDatenbankUrl)("Migration der Korrespondenten", () => {
  const url = new URL(testDatenbankUrl!);
  const name = `${decodeURIComponent(url.pathname.slice(1))}_korr`;
  const ziel = Object.assign(new URL(url), { pathname: `/${name}` }).toString();
  let ordner: string;

  async function admin<T>(f: (sql: postgres.Sql) => Promise<T>): Promise<T> {
    const sql = postgres(testAdminUrl!, { max: 1, onnotice: () => {} });
    try {
      return await f(sql);
    } finally {
      await sql.end();
    }
  }

  beforeAll(async () => {
    await admin(async (sql) => {
      await sql`drop database if exists ${sql(name)} with (force)`;
      await sql`create database ${sql(name)}`;
    });
    // Stand vor dieser Migration: dieselben Dateien, das Journal ohne 0040 und alles danach
    ordner = await mkdtemp(join(tmpdir(), "belegt-migration-"));
    await cp(MIGRATIONEN, ordner, { recursive: true });
    const journal = JSON.parse(await readFile(join(ordner, "meta", "_journal.json"), "utf8"));
    const bis = journal.entries.findIndex((e: { tag: string }) => e.tag === "0040_korrespondenten");
    await writeFile(
      join(ordner, "meta", "_journal.json"),
      JSON.stringify({ ...journal, entries: journal.entries.slice(0, bis) }),
    );
  });
  afterAll(async () => {
    await admin((sql) => sql`drop database if exists ${sql(name)} with (force)`);
    await rm(ordner, { recursive: true, force: true });
  });

  it("legt aus den Freitexten Korrespondenten an und ordnet sie zu, ohne versiegelte Zeilen zu ändern", async () => {
    await migrieren(ziel, ordner);
    const sql = postgres(ziel, { max: 1, onnotice: () => {} });
    try {
      const dokument = (dateiname: string, ...einordnungen: (string | null)[]) =>
        sql.begin(async (tx) => {
          await tx`select set_config('belegt.actor', 'test', true)`;
          const [d] = await tx`insert into dokumente (sha256, groesse, mime_type, dateiname, quelle)
                             values (${"b".repeat(64)}, 1, 'text/plain', ${dateiname}, 'upload') returning id`;
          for (const [i, k] of einordnungen.entries())
            await tx`insert into einordnungen (dokument_id, art, entstanden, frist_bis, korrespondent, erstellt_am)
                     values (${d!.id}, 'frei', '2026-01-01', null, ${k}, now() + ${`${i} seconds`}::interval)`;
          return d!.id as string;
        });
      await dokument("a", "Muster GmbH");
      const b = await dokument("b", " muster gmbh ");
      // Maßgeblich ist die neueste Einordnung
      await dokument("c", "Alt AG", "Telekom");
      const ohne = await dokument("ohne", null);
      const leer = await dokument("leer", "   ");
      const offen = await dokument("offen");
      const weg = await dokument("weg", "Gelöscht AG");
      await sql.begin(async (tx) => {
        await tx`select set_config('belegt.actor', 'test', true)`;
        await tx`insert into loeschungen (dokument_id, beantragt_von) values (${weg}, 'nutzer:a')`;
        await tx`update loeschungen set bestaetigt_von = 'nutzer:b', bestaetigt_am = now() where dokument_id = ${weg}`;
      });

      const einordnungenVorher = await sql`select * from einordnungen order by id`;
      const siegelVorher = await sql`select * from seals order by table_name, row_id`;

      await migrieren(ziel);

      const liste = await sql`select name, abgleich from korrespondenten order by lower(name)`;
      expect(liste).toEqual([
        { name: "Muster GmbH", abgleich: "automatisch" },
        { name: "Telekom", abgleich: "automatisch" },
      ]);
      const zuordnung = await sql`select d.dateiname, k.name from dokument_korrespondenten dk
                                    join dokumente d on d.id = dk.dokument_id
                                    join korrespondenten k on k.id = dk.korrespondent_id order by d.dateiname`;
      expect(zuordnung).toEqual([
        { dateiname: "a", name: "Muster GmbH" },
        { dateiname: "b", name: "Muster GmbH" },
        { dateiname: "c", name: "Telekom" },
      ]);
      for (const id of [ohne, leer, offen, weg])
        expect(await sql`select 1 from dokument_korrespondenten where dokument_id = ${id}`).toHaveLength(0);

      // Die versiegelten Einordnungen und ihre Siegel sind unverändert, die Kette ist intakt
      expect(await sql`select * from einordnungen order by id`).toEqual(einordnungenVorher);
      expect(await sql`select * from seals order by table_name, row_id`).toEqual(siegelVorher);
      expect(await sql`select * from belegt_integrity_problems(10)`).toEqual([]);
      const protokoll = await sql`select distinct actor, table_name from audit_log
                                   where table_name in ('korrespondenten', 'dokument_korrespondenten')`;
      expect(protokoll.map((p) => p.actor)).toEqual(["system:migration", "system:migration"]);
      // Die Suche findet den Namen aus der Liste
      const [s] = await sql`select text from suchtexte where dokument_id = ${b}`;
      expect(s!.text).toContain("Muster GmbH");
    } finally {
      await sql.end();
    }
  });
});
