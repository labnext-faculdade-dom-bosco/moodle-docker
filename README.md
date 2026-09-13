# Instalação do Moodle via Docker

Sobe uma instância do Moodle v5.2.2 com Docker Compose: Apache + PHP (imagem oficial
`moodlehq/moodle-php-apache`), código do Moodle baixado direto do moodle.org.

## Iniciando

Copia o `.env.example` pra `.env` (e ajusta o que quiser: senha do admin,
porta, etc):

```bash
copy .env.example .env
```

Depois:

```bash
docker compose up -d --build
```

Na primeira vez demora um pouco, pois é necessário baixar as imagens, o Moodle, o pacote
de idioma e executar a instalação via CLI. É possível acompanhar com:

```bash
docker compose logs -f moodle
```

Quando aparecer `Instalação do Moodle concluída.` e o Apache subir, o site já
está pronto em `http://localhost:8080` (ou na porta que você definiu em
`MOODLE_PORT`). O usuário e a senha do admin são os que ficaram configurados
em `MOODLE_ADMIN_USER` / `MOODLE_ADMIN_PASSWORD` no seu `.env`.

Por padrão os containers não reiniciam sozinhos (`RESTART_POLICY=no`). Se for
rodar isso em um servidor e quiser que suba de novo automaticamente após
reboot, é necessário alterar pra `RESTART_POLICY=always` no `.env`.

## Web services / API

O container já sobe com os web services habilitados, protocolo REST ativo e
o serviço "Moodle mobile web service" ligado, que já expõe boa parte das
funções core do Moodle (cursos, usuários, matrículas, mensagens, etc). Um
token do admin também é gerado automaticamente na primeira inicialização.

Pra resgatar o token:

```bash
docker compose exec moodle cat /var/www/moodledata/webservice_token.txt
```

Pra testar uma chamada:

```bash
curl "http://localhost:8080/webservice/rest/server.php?wstoken=<SEU_TOKEN>&wsfunction=core_webservice_get_site_info&moodlewsrestformat=json"
```

Troca `<SEU_TOKEN>` pelo valor que saiu do comando anterior. `core_webservice_get_site_info`
retorna, entre outras coisas, a lista completa de funções disponíveis nesse
serviço (campo `functions`), é só trocar o `wsfunction` da URL pra chamar
outra.

## Parar containers / Resetar instalação

```bash
docker compose down        # para os containers, mantém os dados
docker compose down -v     # apaga tudo (banco, site instalado) e volta do zero
```

