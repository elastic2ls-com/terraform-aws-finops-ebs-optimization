
# Changelog

Alle wichtigen Änderungen an diesem Projekt werden in diesem Dokument dokumentiert.

Das Format basiert auf [Keep a Changelog](https://keepachangelog.com/de/1.0.0/).

## [Unreleased]

- Hinzufügen von .github Actions Workflow
- Erstellen eines Beispielprojekts in `examples/basic`
- README.md und CHANGELOG.md hinzugefügt

## [v1.0.0] – 2024-05-XX

- Erstveröffentlichung
- Überwachung von EBS-Volumes (BurstBalance, ReadOps, WriteOps)
- Dynamische Alarmschwellen pro Volumentyp (gp2, gp3, io1, io2, st1, sc1)
- Tag-basierte Filterung (`Environment = Production`)
- SNS-Integration mit konfigurierbarem Email-Empfänger
- Beispiele und CI/CD-Pipeline mit Checkov-Sicherheitsprüfungen

## Lizenz

Dieses Projekt steht unter der [MIT-Lizenz](./LICENSE).
