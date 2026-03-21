# Svatební checklist

Projekt teď obsahuje dvě verze aplikace:

- mobilní a webovou PWA verzi pro iPhone a další zařízení
- původní desktopovou Windows verzi přes PowerShell

## Doporučené spuštění

Pro novou mobilní verzi spusťte `Spustit-PWA-server.bat` a otevřete:

- `http://localhost:8080/` na tomto počítači
- `http://IP-ADRESA-PC:8080/` na telefonu ve stejné Wi‑Fi síti

## PWA funkce

- mobile-first rozhraní s velkými tlačítky
- responzivní layout pro telefon i desktop
- `manifest.json` pro instalaci na plochu
- `service-worker.js` pro cache a offline základ
- banner s instalací a pokyny pro iPhone
- ukládání dat do `localStorage`

## Důležitá poznámka pro iPhone

Pro plnohodnotné PWA chování na skutečném iPhonu mimo `localhost` bývá potřeba `HTTPS`. Pro lokální síť je tedy nejlepší další krok nasadit aplikaci na zabezpečený hosting nebo přidat HTTPS server.

## Původní desktopová verze

Pokud chcete otevřít starší desktopovou variantu pro Windows, spusťte `Spustit-svatebni-checklist.bat`.
