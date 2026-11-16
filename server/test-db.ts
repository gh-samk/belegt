import postgres from "postgres";
import { migrieren } from "./db/migrieren.ts";

/*
 * Tests gegen Postgres laufen nur mit TEST_DATABASE_URL. Die Datenbank dort ist nur der Einstieg: Daneben legt der Lauf
 * <name>_vorlage an (einmal migriert, globalSetup) und je Vitest-Worker <name>_<Nummer> als Kopie davon, damit Dateien
 * parallel laufen. Alle werden dabei gelöscht und neu angelegt; nie auf einen Server mit echten Daten zeigen lassen.
 */
const basis = process.env.TEST_DATABASE_URL;

function mitDatenbank(url: string, name: string): string {
  const u = new URL(url);
  u.pathname = `/${name}`;
  return u.toString();
}

const name = (url: string) => decodeURIComponent(new URL(url).pathname.slice(1));
const vorlage = (url: string) => `${name(url)}_vorlage`;

/** Datenbank dieses Workers; ohne TEST_DATABASE_URL undefined */
export const testDatenbankUrl = basis && mitDatenbank(basis, `${name(basis)}_${process.env.VITEST_POOL_ID ?? "1"}`);

/**
 * Einstieg zum Anlegen und Löschen eigener Datenbanken in einem Test. Die Datenbank des Workers taugt dafür nicht: Sie
 * gibt es erst, wenn eine Datei in diesem Worker testDatenbank() aufgerufen hat.
 */
export const testAdminUrl = basis;

async function neuAnlegen(url: string, datenbank: string, aus?: string): Promise<void> {
  const admin = postgres(url, { max: 1, onnotice: () => {} });
  try {
    await admin`drop database if exists ${admin(datenbank)} with (force)`;
    if (aus) await admin`create database ${admin(datenbank)} template ${admin(aus)}`;
    else await admin`create database ${admin(datenbank)}`;
  } finally {
    await admin.end();
  }
}

/** globalSetup: Vorlage einmal je Lauf frisch anlegen und migrieren */
export async function setup(): Promise<void> {
  if (!basis) return;
  await neuAnlegen(basis, vorlage(basis));
  await migrieren(mitDatenbank(basis, vorlage(basis)));
}

/** In einer Testdatei: eigene Datenbank aus der Vorlage; die Verbindung schließt der Test */
export async function testDatenbank(): Promise<postgres.Sql> {
  if (!basis || !testDatenbankUrl) throw new Error("TEST_DATABASE_URL fehlt");
  await neuAnlegen(basis, name(testDatenbankUrl), vorlage(basis));
  return postgres(testDatenbankUrl, { max: 2, onnotice: () => {} });
}
