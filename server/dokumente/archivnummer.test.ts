import { cp, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import postgres from "postgres";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { MIGRATIONEN, migrieren } from "../db/migrieren.ts";
import { testApp } from "../test-app.ts";
import { testAdminUrl, testDatenbankUrl } from "../test-db.ts";
import { archivnummerAus } from "./dokumente.ts";

describe("archivnummerAus", () => {
  it("liest „ASN 123“, „asn123“ und eine bloße Zahl, sonst nichts", () => {
    expect(archivnummerAus("ASN 123")).toBe(123);
    expect(archivnummerAus(" asn0042 ")).toBe(42);
    expect(archivnummerAus("7")).toBe(7);
    expect(archivnummerAus("Rechnung 7")).toBeNull();
    expect(archivnummerAus("ASN")).toBeNull();
    expect(archivnummerAus(undefined)).toBeNull();
  });
});

describe.skipIf(!testDatenbankUrl)("Archivnummern gegen Postgres", () => {
  let t: Awaited<ReturnType<typeof testApp>>;
  let cookie: string;
  const anfrage = (pfad: string, init: RequestInit = {}) => t.anfrage(pfad, init, cookie);

  beforeAll(async () => {
    t = await testApp();
    cookie = (await t.registrieren("anna@example.org")).cookie;
  });
  afterAll(() => t?.aufraeumen());

  async function hochladen(name: string, inhalt = name) {
    const form = new FormData();
    form.append("datei", new File([new TextEncoder().encode(inhalt)], name));
    return (await anfrage("/api/dokumente", { method: "POST", body: form })).json() as Promise<{
      id: string;
      asn: number;
    }>;
  }

  it("vergibt fortlaufende Nummern beim Eingang, auch für Mails, und zeigt sie in Liste und Dokument", async () => {
    const a = await hochladen("a.txt");
    const b = await hochladen("b.txt");
    expect(b.asn).toBe(a.asn + 1);
    const form = new FormData();
    const mail = "From: a@example.org\r\nSubject: Test\r\nMessage-ID: <asn@example.org>\r\n\r\nHallo\r\n";
    form.append("datei", new File([new TextEncoder().encode(mail)], "test.eml"));
    const { neu } = await (await anfrage("/api/mails", { method: "POST", body: form })).json();
    const m = await (await anfrage(`/api/dokumente/${neu[0]}`)).json();
    expect(m.asn).toBe(b.asn + 1);
    expect((await (await anfrage(`/api/dokumente/${a.id}`)).json()).asn).toBe(a.asn);
    const liste = await (await anfrage("/api/dokumente")).json();
    expect(liste.find((d: { id: string }) => d.id === b.id).asn).toBe(b.asn);
  });

  it("lässt eine Nummer weder ändern noch löschen, und sie ist versiegelt", async () => {
    const d = await hochladen("fest.txt");
    await expect(t.sql`update archivnummern set nummer = 999 where dokument_id = ${d.id}`).rejects.toThrow();
    await expect(t.sql`delete from archivnummern where dokument_id = ${d.id}`).rejects.toThrow(
      /darf nur ergänzt werden/,
    );
    await expect(t.sql`truncate archivnummern cascade`).rejects.toThrow();
    // Eine zweite Nummer für dasselbe Dokument oder eine schon vergebene Nummer lehnt Postgres ab
    await expect(t.sql`insert into archivnummern (dokument_id) values (${d.id})`).rejects.toThrow();
    const [s] = await t.sql`select count(*)::int as n from seals s join archivnummern a on a.id = s.row_id
                             where a.dokument_id = ${d.id}`;
    expect(s!.n).toBe(1);
    expect((await (await anfrage("/api/pruefung")).json()).ok).toBe(true);
  });

  it("findet ein Dokument über „ASN 123“ und über die bloße Nummer", async () => {
    const d = await hochladen("ohne-treffer-im-namen.txt");
    const ids = async (q: string) =>
      (await (await anfrage(`/api/dokumente?suche=${encodeURIComponent(q)}`)).json()).map((x: { id: string }) => x.id);
    expect(await ids(`ASN ${d.asn}`)).toEqual([d.id]);
    expect(await ids(`asn${d.asn}`)).toEqual([d.id]);
    expect(await ids(String(d.asn))).toContain(d.id);
    expect(await ids("ASN 999999")).toEqual([]);
  });
});

describe.skipIf(!testDatenbankUrl)("Migration der Archivnummern", () => {
  const url = new URL(testDatenbankUrl!);
  const name = `${decodeURIComponent(url.pathname.slice(1))}_asn`;
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
    // Stand vor dieser Migration: dieselben Dateien, das Journal ohne 0026 und alles danach
    ordner = await mkdtemp(join(tmpdir(), "belegt-migration-"));
    await cp(MIGRATIONEN, ordner, { recursive: true });
    const journal = JSON.parse(await readFile(join(ordner, "meta", "_journal.json"), "utf8"));
    const bis = journal.entries.findIndex((e: { tag: string }) => e.tag === "0026_archivnummern");
    await writeFile(
      join(ordner, "meta", "_journal.json"),
      JSON.stringify({ ...journal, entries: journal.entries.slice(0, bis) }),
    );
  });
  afterAll(async () => {
    await admin((sql) => sql`drop database if exists ${sql(name)} with (force)`);
    await rm(ordner, { recursive: true, force: true });
  });

  it("gibt dem Altbestand Nummern in der Reihenfolge des Eingangs, neue Dokumente zählen weiter", async () => {
    await migrieren(ziel, ordner);
    const sql = postgres(ziel, { max: 1, onnotice: () => {} });
    try {
      const neu = (dateiname: string, am: string) =>
        sql.begin(async (tx) => {
          await tx`select set_config('belegt.actor', 'test', true)`;
          const [d] = await tx`insert into dokumente (sha256, groesse, mime_type, dateiname, quelle, eingegangen_am)
                             values (${"a".repeat(64)}, 1, 'text/plain', ${dateiname}, 'upload', ${am}) returning id`;
          return d!.id as string;
        });
      // In anderer Reihenfolge eingefügt, als sie eingegangen sind
      const spaet = await neu("spät", "2025-03-01T10:00:00Z");
      const frueh = await neu("früh", "2024-01-01T10:00:00Z");
      const mitte = await neu("mitte", "2024-06-01T10:00:00Z");

      await migrieren(ziel);
      const nummern = await sql`select dokument_id, nummer::int from archivnummern order by nummer`;
      expect(nummern).toEqual([
        { dokument_id: frueh, nummer: 1 },
        { dokument_id: mitte, nummer: 2 },
        { dokument_id: spaet, nummer: 3 },
      ]);
      const danach = await neu("danach", "2026-01-01T10:00:00Z");
      const [n] = await sql`select nummer::int from archivnummern where dokument_id = ${danach}`;
      expect(n!.nummer).toBe(4);
      expect(await sql`select * from belegt_integrity_problems(10)`).toEqual([]);
    } finally {
      await sql.end();
    }
  });
});
