# Sprawozdanie - Zadanie 2 (Łańcuch CI/CD w GitHub Actions)
Autor: Jakub Gwozdowski
## 1. Opis zrealizowanego łańcucha 
Zgodnie z wymaganiami zadania, przygotowano łańcuch GitHub Actions (`.github/workflows/ci.yml`), który automatyzuje proces budowania, skanowania i publikacji obrazu kontenera.

Etapy działania łańcucha:
1. **Checkout & Konfiguracja:** Pobranie kodów źródłowych z repozytorium oraz konfiguracja środowisk QEMU i Docker Buildx (wymagane do obsługi wielu architektur sprzętowych - linux/arm64 i linux/amd64).
2. **Logowanie:** Uwierzytelnienie w usłudze DockerHub (w celu zapisu i odczytu cache) oraz w GHCR z wykorzystaniem mechanizmu bezpieczeństwa Secrets.
3. **Budowa obrazu lokalnego i Skanowanie (Trivy):** Obraz jest budowany lokalnie na serwerze CI (bez jego wcześniejszej publikacji). Następnie uruchamiany jest test CVE przy pomocy skanera **Trivy**. Łańcuch został skonfigurowany tak, by przerwać działanie (exit-code 1), jeśli w obrazie znajdą się podatności o poziomie `CRITICAL` lub `HIGH`. Wybrano skaner Trivy, ponieważ integruje się on z łańcuchami CI/CD w postaci dedykowanej akcji GitHub i nie wymaga wysyłania niesprawdzonego obrazu do zewnętrznego rejestru w celu wykonania skanu.
4. **Budowa Multi-arch i Push:** Tylko po pomyślnym przejściu skanowania CVE, uruchamiany jest drugi etap: właściwe budowanie dla architektur `linux/amd64` oraz `linux/arm64`. Gotowy, bezpieczny obraz przesyłany jest do publicznego repozytorium na Github (ghcr.io).
5. **Obsługa Cache:** W procesie budowy wykorzystywane są dane cache (wysyłanie i pobieranie). Jako eksporter i backend użyto publicznego rejestru DockerHub (`registry`) w trybie `max`.

## 2. Tagowania i Uzasadnienie
W łańcuchu wykorzystano oficjalną akcję `docker/metadata-action` do zautomatyzowanego zarządzania tagami. Przyjęto następujący system:

* **Obraz aplikacyjny (GHCR):** Tagowany jest na dwa sposoby: jako `latest` oraz unikalnym, krótkim hashem commita z Git (np. `sha-8a2b3c4`).
    * *Uzasadnienie:* Tagi oparte na skrótach kryptograficznych (tzw. *immutable tags*)zapewniają 100% identyfikowalności – administrator ma pewność, z jakiej dokładnie wersji kodu na GitHubie powstał dany kontener. Zapobiega to przypadkowemu nadpisaniu i uruchomieniu błędnego kodu. Źródła: https://github.com/docker/metadata-action https://docs.docker.com/dhi/core-concepts/digests/
* **Obraz Cache (DockerHub):** Zapisywany na DockerHub z tagiem odpowiadającym nazwie gałęzi (w tym przypadku `:main`).
    * *Uzasadnienie:* Taki schemat gwarantuje, że dane cache z różnych środowisk/gałęzi nie nadpisują się nawzajem, co zwiększa wydajność budowania. Źródła: https://docs.docker.com/build/cache/backends/registry/

## 3. Adresy repozytoriów
* **Obraz (GHCR):** `https://github.com/JakubGwo/PAwChOZadanie2/pkgs/container/pawchozadanie2`
* **Cache (DockerHub):** https://hub.docker.com/repository/docker/jakgwo/pogoda-app-cache