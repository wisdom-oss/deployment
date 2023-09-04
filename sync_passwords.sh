set -o allexport
source .env set
+o allexport
echo -e "${PG_PASS}" > ./.secrets/.pgpass
echo -e "${AMQP_PASS}" > ./.secrets/.amqppass
