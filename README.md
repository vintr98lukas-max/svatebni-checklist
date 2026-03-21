# Svatební checklist

Projekt obsahuje dvě verze aplikace:

- novou webovou/PWA verzi pro iPhone, Android a desktop
- původní desktopovou Windows verzi přes PowerShell

## Doporučené použití

### Lokálně na tomto počítači

Spusťte `Spustit-PWA-server.bat` a otevřete:

- `http://localhost:8080/` na tomto počítači
- `http://IP-ADRESA-PC:8080/` na telefonu ve stejné Wi-Fi síti

To je vhodné pro testování rozhraní. Na iPhonu ale tato varianta nestačí pro skutečnou instalaci a spolehlivý offline režim.

### Skutečná instalace na iPhone a offline režim

Pro iPhone je potřeba aplikaci otevřít přes `HTTPS`. Jakmile běží na zabezpečené adrese:

1. otevřete ji v Safari
2. klepněte na `Sdílet`
3. zvolte `Přidat na plochu`
4. spusťte ji z ikony na ploše

Po prvním načtení si aplikace uloží hlavní soubory do cache a může fungovat i bez připojení.

## Co už je připravené

- `manifest.json` pro instalaci na plochu
- `service-worker.js` pro offline cache aplikace
- `offline.html` jako záložní offline obrazovka
- instrukce v aplikaci pro iPhone i ostatní zařízení
- ukládání checklistu a data svatby do `localStorage`
- `vercel.json` pro snadné nasazení na Vercel s automatickým HTTPS

## Nejjednodušší cesta k HTTPS

Nejrychlejší je nasadit projekt na Vercel. Projekt je na to připravený:

1. vytvořte repozitář na GitHubu
2. nahrajte do něj obsah této složky
3. ve Vercelu zvolte `New Project`
4. propojte GitHub repozitář a nasaďte projekt
5. otevřete výslednou `https://...vercel.app` adresu na iPhonu v Safari

## Původní desktopová verze

Pokud chcete otevřít starší desktopovou variantu pro Windows, spusťte `Spustit-svatebni-checklist.bat`.
