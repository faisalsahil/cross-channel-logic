COLOR="\033[1;31m"
RESET="\033[0;00m"

echo -e "$COLOR Running the ableform Setup Script... this could take a minute... $RESET"

#echo -e "$COLOR Stopping the database$RESET"
#pg_ctl -D /usr/local/var/postgres stop -s -m fast

echo -e "$COLOR Bundling everything together with a nice little bow...$RESET"
heroku run bundle --app cross-channel-app

echo -e "$COLOR Dropping the database... boom!!!$RESET"
heroku pg:reset HEROKU_POSTGRESQL_ORANGE --confirm cross-channel-app

echo -e "$COLOR Creating shiney new database... fresh!$RESET"
heroku run rake db:create --app cross-channel-app

echo -e "$COLOR Migrating the database. Wow, this is fun!$RESET"
heroku run rake db:migrate --app cross-channel-app

echo -e "$COLOR Seeding the database... it's growing...$RESET"
heroku run rake db:seed --app cross-channel-app

echo -e "$COLOR Populating the database with just enough data so this app don't crash...$RESET"

#echo -e "$COLOR starting postgres$RESET"
#pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start

echo -e "$COLOR Opening the browser"
heroku open --app cross-channel-app