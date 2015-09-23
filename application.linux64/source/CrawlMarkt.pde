import de.bezier.data.sql.*;

import com.temboo.core.*;
import com.temboo.Library.Google.Gmailv2.Messages.*;
import com.temboo.Library.Google.OAuth.*;

TembooSession session = new TembooSession("markt", "myFirstApp", "57a4114344d04169b18ed0662bc14e5d");

PrintWriter log;
// int comeco, fim = 0;
int counterDuplicatasZS, counterProdutosBancoZS, counterProdutosCrawlZS, counterTempoZS = 0;
int counterDuplicatasGPA, counterProdutosBancoGPA, counterProdutosCrawlGPA, counterTempoGPA = 0;
int counterDuplicatasExtra, counterProdutosBancoExtra, counterProdutosCrawlExtra, counterTempoExtra = 0;
PostgreSQL pgsql;
String user, pass, database, host, path = "";
int wait, comeco, fim, waitBottom, waitTop = 0;
boolean sendEmail = false;
String dia, mes, ano = "";
String refreshtoken = "";
String settingsPath = "/usr/share/nginx/html/Markt/Settings.txt";
// String settingsPath = "/Users/brunobaring/Desktop/Markt/Settings.txt";


// ya29.7wGs9MdHlfFKgYJkeBLCw9R-DDDE9zuxV7FYo3qvtFoAIivuPpAPgvT6MFJ0XiReo44e
void setup() {

 inita();

 displaySum();
}

void draw() {
  exit();
}


//  try {
//    dropDB();
//  }
//  catch ( java.sql.SQLException e ) {
//    e.printStackTrace();
//    println("Conexao FECHOU, q merda!");
//    exit();
//  }
