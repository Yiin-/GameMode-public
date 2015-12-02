/*
 * server/database
 *
 * Serverio duomenø bazë
 */

#include <a_mysql>
#include <YSI_Coding\y_hooks>

#define _host "localhost"
#define _database "gamemode"
#define _username "root"
#define _password ""
#define _password_host "justas"

new database;
new query[2000];

hook OnGameModeInit() {
	// #define filename "sql_create_database.txt"

	// if(file_exists(filename)) {
	// 	new File:file = fopen(filename, io_read);

	// 	if(file) {
	// 		fread(file, query);
			
			mysql_log();
   
			database = mysql_connect(_host, _username, _database, _password_host);
			if(mysql_errno() != 0) {
				database = mysql_connect(_host, _username, _database, _password);
				if(mysql_errno() != 0) {
					print("\n\n\nCAN'T CONNECT TO DATABASE\n\n\n");
					SendRconCommand("exit");
				}
			}

			if(mysql_errno()) {
				printf("MySQL Error: %i", mysql_errno());
			}
			else {
				printf("Successfully connected to database");
			}

	// 		mysql_query(database, query, .use_cache = false);
	// 	}
	// }
	// #undef filename
}

hook OnGameModeExit() {
	mysql_close(database);
}