# Sprawozdanie - Zadanie 2 (Łańcuch CI/CD w GitHub Actions)

## 1. Opis zrealizowanego łańcucha (Pipeline)
[cite_start]Zgodnie z wymaganiami zadania, przygotowano łańcuch GitHub Actions (`.github/workflows/ci.yml`), który automatyzuje proces budowania, skanowania i publikacji obrazu kontenera[cite: 4, 5].

Łańcuch realizuje następujące etapy:
1. [cite_start]**Checkout & Konfiguracja:** Pobranie kodów źródłowych z repozytorium [cite: 4] oraz konfiguracja środowisk QEMU i Docker Buildx (wymagane do obsługi wielu architektur).
2. [cite_start]**Logowanie:** Uwierzytelnienie w usłudze DockerHub (w celu zapisu i odczytu cache [cite: 8][cite_start]) oraz w GitHub Container Registry (GHCR) [cite: 4] z wykorzystaniem bezpiecznych poświadczeń (GitHub Secrets).
3. **Budowa obrazu lokalnego i Skanowanie (Trivy):** Obraz jest budowany lokalnie na serwerze CI (bez jego wcześniejszej publikacji). [cite_start]Następnie uruchamiany jest test CVE przy pomocy skanera **Trivy**. [cite_start]Łańcuch został skonfigurowany tak, by przerwać działanie (exit-code 1), jeśli w obrazie znajdą się podatności o poziomie `CRITICAL` lub `HIGH`[cite: 9]. [cite_start]Wybrano skaner Trivy, ponieważ idealnie integruje się on z łańcuchami CI/CD w postaci dedykowanej akcji GitHub i nie wymaga wysyłania niesprawdzonego obrazu do zewnętrznego rejestru w celu wykonania skanu[cite: 13].
4. [cite_start]**Budowa Multi-arch i Push:** Tylko po pomyślnym przejściu skanowania CVE [cite: 9][cite_start], uruchamiany jest drugi etap: właściwe budowanie dla architektur `linux/amd64` oraz `linux/arm64`[cite: 6]. [cite_start]Gotowy, bezpieczny obraz przesyłany jest do publicznego repozytorium autora na Github (ghcr.io)[cite: 4].
5. **Obsługa Cache:** W procesie budowy wykorzystywane są dane cache (wysyłanie i pobieranie). [cite_start]Jako eksporter i backend użyto publicznego rejestru DockerHub (`registry`) w trybie `max`[cite: 7, 8].

## 2. Strategia Tagowania i Uzasadnienie
W łańcuchu wykorzystano oficjalną akcję `docker/metadata-action` do zautomatyzowanego zarządzania tagami. [cite_start]Przyjęto następujący system[cite: 10]:

* **Obraz aplikacyjny (GHCR):** Tagowany jest na dwa sposoby: jako `latest` (zawsze wskazuje na najnowszą udaną kompilację) oraz unikalnym, krótkim hashem commita z Git (np. `sha-8a2b3c4`).
    * [cite_start]*Uzasadnienie[cite: 11]:* Tagi oparte na skrótach kryptograficznych (tzw. *immutable tags*) to standard branżowy. Zapewniają one 100% identyfikowalności – administrator ma pewność, z jakiej dokładnie wersji kodu na GitHubie powstał dany kontener. Zapobiega to przypadkowemu nadpisaniu i uruchomieniu błędnego kodu na produkcji.
* **Obraz Cache (DockerHub):** Zapisywany na DockerHub z tagiem odpowiadającym nazwie gałęzi (w tym przypadku `:main`).
    * [cite_start]*Uzasadnienie[cite: 11]:* Taki schemat gwarantuje, że dane cache z różnych środowisk/gałęzi (np. testowych i produkcyjnych) nie nadpisują się nawzajem, co zwiększa wydajność budowania w złożonych projektach.

## 3. Adresy repozytoriów
* **Obraz (GHCR):** `[TUTAJ WKLEISZ LINK DO PACZKI PO ZAKOŃCZENIU]`
* **Cache (DockerHub):** https://hub.docker.com/repository/docker/jakgwo/pogoda-app-cache