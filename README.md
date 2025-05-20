# Guida per l'esecuzione automatica dei test Atomic per Windows

Questa guida fornisce i passaggi necessari per eseguire automaticamente i test di **Atomic Red Team**, su un sistema Windows, utilizzando script PowerShell. I test vengono lanciati dalla finestra di powershell e hanno un tempo di 120 secondi per terminare, diversamente l'arresto viene forzato (opzione modificabile, attualmente impostata ai valori di default di Invoke Atomic Red Team).
Per l'inserimento di nuovi test atomic **prestare attenzione alla documentazione degli atomic tests**, che indica in quale ambiente lanciare il test (es. Run with command_prompt! Elevation Required (e.g. root or admin), Run with command_prompt!, Run with PowerShell! Elevation Required (e.g. root or admin), Run with PowerShell!)

---

## Indice

1. [Requisiti e configurazioni necessarie](#requisiti-e-configurazioni-necessarie)

   * Windows PowerShell 5.x o successivo
   * Installazione dei moduli necessari
   * Creazione della cartella di destinazione
   * Scarica e configura la repository Atomic Red Team
   * Aggiungi lo script PowerShell
2. [Esegui lo script PowerShell](#esegui-lo-script-powershell)
3. [Personalizzazione dei test](#personalizzazione-dei-test)
4. [Visualizzazione dei Risultati](#visualizzazione-dei-risultati)

---

## Requisiti e configurazioni necessarie

### 1. Windows PowerShell 5.x o successivo

Per eseguire lo script correttamente, è necessario avere **Windows PowerShell 5.x o successivo**. Puoi verificare la versione di PowerShell con il comando:

```powershell
$PSVersionTable.PSVersion
```

Se la versione è inferiore a 5.x, dovrai aggiornare PowerShell. Puoi scaricarlo dal [sito ufficiale Microsoft](https://docs.microsoft.com/en-us/powershell/scripting/learn/installation).

### 2. Installazione dei moduli necessari

Lo script richiede i seguenti moduli PowerShell:

* **Invoke-AtomicRedTeam**
* **PowerShell-YAML**

Esegui il comando seguente per installarli:

```powershell
Install-Module -Name invoke-atomicredteam, powershell-yaml -Scope CurrentUser
```

Per la verifica della corretta installazione di **`Invoke-AtomicRedTeam`** tramite:

```powershell
Get-Module -ListAvailable | Where-Object { $_.Name -eq 'Invoke-AtomicRedTeam' }
```

Questi moduli ti consentiranno di eseguire i test di Atomic Red Team e di leggere file YAML se necessari.

### 3. Creazione della cartella di destinazione

Per organizzare correttamente il materiale, crea una cartella di destinazione dove memorizzare la repository di Atomic Red Team. Esegui il comando:

```powershell
New-Item -Path "C:\Temp\Mead" -ItemType Directory
```

### 4. Scarica e configura la repository Atomic Red Team

Scarica la repository **atomic-red-team** da GitHub:

1. Vai su [Atomic Red Team GitHub repository](https://github.com/redcanaryco/atomic-red-team) e clicca su **Code > Download ZIP**.
2. Estrai il contenuto del file ZIP nella cartella: **C:\Temp\Mead** 
3. Verifica: dopo aver estratto la zip, dovresti trovare nella cartella il contenuto: **C:\Temp\Mead\atomic-red-team-master**.

   > ⚠️ *Se il nome della cartella estratta è diverso (es. `atomic-red-team-main`), **rinominala** in `atomic-red-team-master`, così da essere compatibile con lo script.*

### 5. Aggiungi lo script PowerShell per l'esecuzione dei test

Scarica o copia lo/gli script **`SCRIPTNAME.ps1`**, disponibili nella cartella **`Atomic_ExecutionScripts`** della repository, e salvalo nella stessa cartella dove hai importato la repository **atomic-red-team**.

---

## Esegui lo script PowerShell

Una volta configurato tutto, esegui lo script PowerShell per avviare i test.

### Passaggi:

1. **Apri PowerShell**:

   * Apri una finestra di powershell o powershell come amministratore se richiesto (powershell con privilegi se AdminRequired, senza privilegi se NotAdmin).

2. **Naviga alla cartella** dove hai salvato lo script e la repository di atomic-red-team:

```powershell
cd "C:\Temp\Mead"
```

3. **Cambia l'execution policy (se necessario)** : Prima di eseguire lo script potrebbe essere necessario modificare la execution policy della macchina; si può fare per il singolo script, utilizzando:

```powershell
powershell -ExecutionPolicy Bypass -File .\SCRIPTNAME.ps1
```
---

## Personalizzazione dei test

### Modificare la tecnica o i numeri dei test:

Per eseguire test diversi diversi da quelli definiti è sufficiente utilizzare la sintassi:

```powershell
@{ Technique = "Technique"; TestNumber = Number }
```

Andando a sostituire a **Technique** la tecnica desiderata (**NON rimuovere i doppi apici**) e a **Number** il numero della tecnica.

---

## Visualizzazione dei Risultati

L'output di ciascun test includerà informazioni sull'orario di inizio. Nella finestra principale vedrai un messaggio che indica l'avvio di ogni test e l'orario di inizio:

```
[2025-05-08 12:30:45] Avvio del test T1047-1
```

E, al termine dell'esecuzione dell'atomic test, verrà richiesto di premere invio per passare al test successivo.

---

