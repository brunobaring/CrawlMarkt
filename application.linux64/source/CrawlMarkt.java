import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import de.bezier.data.sql.*; 
import com.temboo.core.*; 
import com.temboo.Library.Google.Gmailv2.Messages.*; 
import com.temboo.Library.Google.OAuth.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CrawlMarkt extends PApplet {







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
public void setup() {

 inita();

 displaySum();
}

public void draw() {
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
public void Extra() {
  counterTempoExtra = millis();
  
  String input[] = loadStrings("links_Extra.txt");
  fim = input.length;
  comeco = 0;
  // fim = 1;
  // comeco = 295;

  pgsql = new PostgreSQL( this, host, database, user, pass );

  println("Crawl do Extra: COMECOU!");
  log.println("Crawl do Extra: COMECOU!");
  PrintWriter out2put = createWriter(path + dia + ":" + mes + ":" + ano + "/_MASTER_EXTRA_" + dia + ":" + mes + ":" + ano + ".txt");


  for ( int k = comeco; k < fim; k++ ) {
    int qtyPages = 1;
    String partialAddress = input[k].substring(0, input[k].indexOf(",")) + "?sort=&rows=12&q=&offset=";
    String category = input[k].substring(input[k].indexOf("/", 53) + 1, input[k].indexOf(","));

    print("_/,,/  : " + k + "/" + fim + " - " + category);
    log.print("_/,,/  : " + k + "/" + fim + " - " + category);


    out2put.println(category);
    // println(category);
    for ( int j = 1; j <= qtyPages; j++ ) {
      print(" =>  pag " + j + " ...  ");
      log.print(" =>  pag " + j + " ...  ");
      wait(PApplet.parseInt(random(waitBottom, waitTop)*1000));
      String lines[];

      String fullAddress = partialAddress;
      if ( j >= 2 ) {
        fullAddress = partialAddress + (j-1)*12;
      }

      lines = loadStrings(fullAddress);

      for ( int i = 0; i < lines.length; i++) {


        if ( match(lines[i], "Produtos encontrados:") != null) {
          qtyPages = 1 + ((Integer.parseInt(trim(lines[i].substring(lines[i].indexOf("<span>") + 6, lines[i].indexOf("</span>")))))/12);
        }
        //LINK DA FOTO
        if ( match(lines[i], "prdImagem") != null) {
          int b = lines[i].indexOf("src=\"");
          int c = lines[i].indexOf("\" class=");
          if (b != -1 && c != -1) {
            String d = lines[i].substring(b + 5 + 4, c);
            out2put.print(d + ",");
            // println(d);
          }
        }

        //NOME DO PRODUTO
        if ( match(lines[i], "\"prdNome\">") != null && match(lines[i+1], "<span>") != null) {
          String d = lines[i+1].substring(lines[i+1].indexOf("<span>") + 6, lines[i+1].indexOf("</span>"));

          if ( match(d, ",") != null) {
            d = substituiCharNaString(d, ',', '.');
          }

          while ( d.indexOf ("'") != -1 ) {
            d = substituiCharNaString(d, '\'', '\u00b4');
          }

          while ( d.indexOf (";") != -1 ) {
            d = htmlAccent(d);
          }

          counterProdutosCrawlExtra++;
          out2put.print(d + ",");
          // println(d);
        }
        //PRECO
        if ( match(lines[i], "prdPreco prdPrices") != null) {
          // println(lines[i]);
          int b = lines[i].indexOf("</em><strong>");
          String c = lines[i].substring(b + 13, lines[i].indexOf("</strong></span>"));
          out2put.print(c);
          // println(c);
          if (!c.equals("")) {
            out2put.println();
          }
        }
      }
    }


    println("Done!!!");
    log.println("Done!!!");
  }
  out2put.flush();
  out2put.close();

  println("Crawl do Extra: ACABOU!");
  log.println("Crawl do Extra: ACABOU!");
}



public void BD_Extra() {


  info prod = new info();

  String input2[]; 
  input2 = loadStrings(path + dia + ":" + mes + ":" + ano + "/_MASTER_EXTRA_" + dia + ":" + mes + ":" + ano + ".txt");

  //REMOVE DUPLICATAS
  println("Remover Duplicatas do Extra: COMECOU");
  log.println("Remover Duplicatas do Extra: COMECOU");
  for ( int i = 0; i < input2.length; i++ ) {
    if ( input2[i].indexOf(",") != -1 ) {
      String nameFix = "";
      nameFix = input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length()); //retira o link da imagem do input
      nameFix = nameFix.substring(0, nameFix.indexOf(",")); // separa nome do produto
      for ( int k = i+1; k < input2.length; k++ ) {
        if ( input2[k].indexOf(",") != -1 ) {
          String nameFix1 = "";
          nameFix1 = input2[k].substring(input2[k].indexOf(",") + 1, input2[k].length()); //retira o link da imagem do input
          nameFix1 = nameFix1.substring(0, nameFix1.indexOf(",")); // separa nome do produto
          // if (nameFix1.indexOf("\u00b4") != -1 ) {

          if ( nameFix.equals(nameFix1) ) {
            counterDuplicatasExtra++;
            //              println(counterDuplicatasZS + " " + nameFix);
            input2[i] = "";
            k = input2.length;
          }
        }
      }
    }
  }
  println("Remover Duplicatas do Extra: ACABOU");
  log.println("Remover Duplicatas do Extra: ACABOU");
  pgsql = new PostgreSQL( this, host, database, user, pass );
  if ( pgsql.connect() ) {
    println("Inserir no Banco do Extra: COMECOU");
    log.println("Inserir no Banco do Extra: COMECOU");
    String category = "";
    for ( int i = 0; i < input2.length; i++ ) {
      if ( !input2[i].equals("") ) {
        prod.renew();
        if ( input2[i].indexOf(",") == -1 ) {
          category = input2[i].toLowerCase();
          pgsql.query( "INSERT INTO category(name, created_at) SELECT '" + category + "',current_timestamp WHERE NOT EXISTS (SELECT name FROM category where name = '" + category + "');" );
        } else if ( !input2[i].equals("") ) {        
          prod.category = category; //list[j].substring(0, list[j].length()-4);//define nome da categoria
          prod.imageLink = input2[i].substring(0, input2[i].indexOf(",")); //separa link da imagem
          input2[i] = input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length()); //retira o link da imagem do input
          if (input2[i].charAt(0) == '\"') { // se o nome tiver v\u00edrgula no meio (o nome fica separado por aspas quando tem virgula no meio)
            input2[i] = substituiCharNaString(input2[i], '\"', ' ');
            input2[i] = input2[i].substring(0, input2[i].indexOf(",")) + "." + input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length());
          }
          prod.name = input2[i].substring(0, input2[i].indexOf(",")).toLowerCase(); // separa nome do produto
          prod.price = properFloat(input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length())); //retira o nome do input e sobra o preco

          pgsql.query( "INSERT INTO product(name,created_at) SELECT '" + prod.name + "',current_timestamp WHERE NOT EXISTS (SELECT name FROM product WHERE name = '" + prod.name + "') RETURNING id;" );
          if ( pgsql.next() )
          {
            pgsql.query( "CREATE VIEW prod_ID_" + pgsql.getInt(1) + " AS SELECT * FROM register WHERE id_product = " + pgsql.getInt(1) + "; ");
          }
          pgsql.query( "INSERT INTO register(id_product,id_category,id_market,price,datedate,created_at,imagelink) VALUES((SELECT id FROM product WHERE name = '" + prod.name + "'),(SELECT id FROM category WHERE name = '" + prod.category + "'),3," + prod.price + ",current_date,current_timestamp,'" + prod.imageLink + "');" );
          counterProdutosBancoExtra++;
        }
        println("line: " + i + " \t" + prod.name);
      }
      wait(20);
    }
    println("Inserir no Banco do Extra: ACABOU");
    log.println("Inserir no Banco do Extra: ACABOU");
    pgsql.close();
    pgsql = null;
  }
  counterTempoExtra = millis() - counterTempoExtra;
  wait(wait);
}

public void inita() {

  String settings[] = loadStrings(settingsPath);
  user        = settings[0].substring( settings[0].indexOf("=") + 1, settings[0].indexOf(";") );
  pass        = settings[1].substring( settings[1].indexOf("=") + 1, settings[1].indexOf(";") );
  database    = settings[2].substring( settings[2].indexOf("=") + 1, settings[2].indexOf(";") );
  host        = settings[3].substring( settings[3].indexOf("=") + 1, settings[3].indexOf(";") );
  path        = settings[4].substring( settings[4].indexOf("=") + 1, settings[4].indexOf(";") );

  dia        = str(day());
  mes        = str(month());
  ano        = str(year());

  log = createWriter(path + dia + ":" + mes + ":" + ano + "/_LOG_" + dia + ":" + mes + ":" + ano + ".txt");


  for ( int i = 0; i < settings.length; i++ ) {

    String market = settings[i].substring( 0, settings[i].indexOf("=") );
    String action = settings[i].substring( settings[i].indexOf("=") + 1, settings[i].indexOf(";") );
    if ( market.equals("wait") )
      wait = Integer.parseInt(action);
    if ( market.equals("sendEmail") && action.indexOf("y") != -1 )
      sendEmail = true;
    if ( market.equals("comeco") )
      comeco = Integer.parseInt(action);    
    if ( market.equals("fim") )
      fim = Integer.parseInt(action);
    if ( market.equals("waitBottom") )
      waitBottom = Integer.parseInt(action);    
    if ( market.equals("waitTop") )
      waitTop = Integer.parseInt(action);
    if ( market.equals("dropDB") && action.indexOf("y") != -1 )
      dropDB();
    if ( market.equals("ZonaSul") && action.indexOf("c") != -1 )
      ZonaSul();
    if ( market.equals("PaoDeAcucar") && action.indexOf("c") != -1 )
      PaoDeAcucar();
    if ( market.equals("Extra") && action.indexOf("c") != -1 )
      Extra();
    if ( market.equals("ZonaSul") && action.indexOf("b") != -1 )
      BD_ZonaSul();
    if ( market.equals("PaoDeAcucar") && action.indexOf("b") != -1 )
      BD_PaoDeAcucar();
    if ( market.equals("Extra") && action.indexOf("b") != -1 )
      BD_Extra();
  }
}


public void wait( int tempo) {
  //  print(tempo/1000 + "s  ");
  int aux=millis();
  while ( millis ()-aux<tempo) {
  }
}


public void displaySum() {

  println( "#\t\t O Programa encerrou em: \t" + day() + "/" + month() + "/" + year() + " \u00e0s " + hour() + ":" + minute() + ":" + second() ); 

  println("\tZS\tGPA\tExtra");
  println("Crawl\t" + counterProdutosCrawlZS + "\t" + counterProdutosCrawlGPA + "\t" + counterProdutosCrawlExtra);
  println("Banco\t" + counterProdutosBancoZS + "\t" + counterProdutosBancoGPA + "\t" + counterProdutosBancoExtra);
  println("Duplicatas\t" + counterDuplicatasZS + "\t" + counterDuplicatasGPA + "\t" + counterDuplicatasExtra);
  println("Ok?\t" + (counterProdutosCrawlZS - counterDuplicatasZS - counterProdutosBancoZS) + "\t" + (counterProdutosCrawlGPA - counterDuplicatasGPA - counterProdutosBancoGPA) + "\t" + (counterProdutosCrawlExtra - counterDuplicatasExtra - counterProdutosBancoExtra));
  println("Tempo\t" + counterTempoZS/60000 + "\t" + counterTempoGPA/60000 + "\t" + counterTempoExtra/60000);

  println("\nTempo Total: " + ( (counterTempoZS/60000) + (counterTempoGPA/60000) + (counterTempoExtra/60000) ));
  println("\nBanco Total: " + ( (counterProdutosCrawlZS - counterDuplicatasZS - counterProdutosBancoZS) + (counterProdutosCrawlGPA - counterDuplicatasGPA - counterProdutosBancoGPA) + (counterProdutosCrawlExtra - counterDuplicatasExtra - counterProdutosBancoExtra) ));


  //////////////////////////    LOG LOG LOG LOG LOG LOG LOG    //////////////////////////////
  log.println( "#\t\t O Programa encerrou em: \t" + day() + "/" + month() + "/" + year() + " \u00e0s " + hour() + ":" + minute() + ":" + second() ); 

  log.println("\tZS\tGPA\tExtra");
  log.println("Crawl\t" + counterProdutosCrawlZS + "\t" + counterProdutosCrawlGPA + "\t" + counterProdutosCrawlExtra);
  log.println("Banco\t" + counterProdutosBancoZS + "\t" + counterProdutosBancoGPA + "\t" + counterProdutosBancoExtra);
  log.println("Duplicatas\t" + counterDuplicatasZS + "\t" + counterDuplicatasGPA + "\t" + counterDuplicatasExtra);
  log.println("Ok?\t" + (counterProdutosCrawlZS - counterDuplicatasZS - counterProdutosBancoZS) + "\t" + (counterProdutosCrawlGPA - counterDuplicatasGPA - counterProdutosBancoGPA) + "\t" + (counterProdutosCrawlExtra - counterDuplicatasExtra - counterProdutosBancoExtra));
  log.println("Tempo\t" + counterTempoZS/60000 + "\t" + counterTempoGPA/60000 + "\t" + counterTempoExtra/60000);

  log.println("\nTempo Total: " + ( (counterTempoZS/60000) + (counterTempoGPA/60000) + (counterTempoExtra/60000) ));
  log.println("\nBanco Total: " + ( (counterProdutosCrawlZS - counterDuplicatasZS - counterProdutosBancoZS) + (counterProdutosCrawlGPA - counterDuplicatasGPA - counterProdutosBancoGPA) + (counterProdutosCrawlExtra - counterDuplicatasExtra - counterProdutosBancoExtra) ));
  log.flush();
  log.close();

  if ( sendEmail )
    runSendMessageChoreo(prepareEmailMessage());
}

public String prepareEmailMessage() {

  String emailMessage = ""; 

  emailMessage += "#\t\t O Programa encerrou em: \n" + day() + "/" + month() + "/" + year() + " \u00e0s " + hour() + ":" + minute() + ":" + second() ; 

  emailMessage += "\n\n\tZS\tGPA\tExtra";
  emailMessage += "\nCrawl\t" + counterProdutosCrawlZS + "\t" + counterProdutosCrawlGPA + "\t" + counterProdutosCrawlExtra;
  emailMessage += "\nBanco\t" + counterProdutosBancoZS + "\t" + counterProdutosBancoGPA + "\t" + counterProdutosBancoExtra;
  emailMessage += "\nDuplicatas\t" + counterDuplicatasZS + "\t" + counterDuplicatasGPA + "\t" + counterDuplicatasExtra;
  emailMessage += "\nOk?\t" + (counterProdutosCrawlZS - counterDuplicatasZS - counterProdutosBancoZS) + "\t" + (counterProdutosCrawlGPA - counterDuplicatasGPA - counterProdutosBancoGPA) + "\t" + (counterProdutosCrawlExtra - counterDuplicatasExtra - counterProdutosBancoExtra);
  emailMessage += "\nTempo\t" + counterTempoZS/60000 + "\t" + counterTempoGPA/60000 + "\t" + counterTempoExtra/60000;

  emailMessage += "\nTempo Total: " + ( (counterTempoZS/60000) + (counterTempoGPA/60000) + (counterTempoExtra/60000) );
  emailMessage += "\nBanco Total: " + ( (counterProdutosCrawlZS - counterDuplicatasZS - counterProdutosBancoZS) + (counterProdutosCrawlGPA - counterDuplicatasGPA - counterProdutosBancoGPA) + (counterProdutosCrawlExtra - counterDuplicatasExtra - counterProdutosBancoExtra) );


  return emailMessage;
}


public float properFloat(String a) {
  if (a.equals("")) {
    return 0.0f;
  } else {
    String unidades = a.substring(0, a.indexOf(","));
    if ( unidades.indexOf(".") != -1 ) {
      unidades = unidades.substring(0, unidades.indexOf(".")) + unidades.substring(unidades.indexOf(".") + 1, unidades.length());
    }
    return PApplet.parseFloat(unidades + "." + a.substring(a.indexOf(",") + 1, a.length()));
  }
}

public String substituiCharNaString(String a, char c1, char c2) {
  int aux = 0;
  for ( int i = 0; i < a.length (); i++ ) {
    if ( a.charAt(i) == c1 ) {
      aux++;
    }
  }

  for ( int i = 0; i < aux; i++) {
    a = a.substring(0, a.indexOf(c1)) + c2 + a.substring(a.indexOf(c1)+1, a.length());
  }
  return a;
}

class info {
  String imageLink = "";
  float  price = 0.0f;
  String name = "";
  String date = "";
  String category = "";
  info() {
  }

  public void renew() {
    imageLink = "";
    price = 0.0f;
    name = "";
    date = "";
    category = "";
  }
}



public String htmlAccent(String a) {

  String inicio = "";
  String fim = "";

  String b = a.substring(a.indexOf(";") - 4, a.indexOf(";") + 1);
  if ( b.equals( "eamp;" ) ) {
    inicio = a.substring(0, a.indexOf( "eamp;" ));
    fim = a.substring(a.indexOf( "eamp;" ) + 5);
    return inicio + "e" + fim;
  }

  inicio = a.substring(0, a.indexOf( "&" ));
  fim = a.substring(a.indexOf( ";" ) + 1, a.length());

  b = a.substring( a.indexOf( "&" ) + 1, a.indexOf( ";" ) ); 

  if ( b.equals( "Aacute" ) ) {  
    return inicio + "\u00c1" + fim;
  } else if ( b.equals( "aacute" ) ) {  
    return inicio + "a" + fim;
  } else if ( b.equals( "Acirc" ) ) {  
    return inicio + "\u00c2" + fim;
  } else if ( b.equals( "acirc" ) ) {  
    return inicio + "\u00e2" + fim;
  } else if ( b.equals( "Agrave" ) ) {  
    return inicio + "\u00c1" + fim;
  } else if ( b.equals( "agrave" ) ) {  
    return inicio + "\u00e1" + fim;
  } else if ( b.equals( "Atilde" ) ) {  
    return inicio + "\u00c3" + fim;
  } else if ( b.equals( "atilde" ) ) {  
    return inicio + "\u00e3" + fim;
  } else if ( b.equals( "Eacute" ) ) {  
    return inicio + "\u00c9" + fim;
  } else if ( b.equals( "eacute" ) ) {  
    return inicio + "\u00e9" + fim;
  } else if ( b.equals( "Ecirc" ) ) {  
    return inicio + "\u00ca" + fim;
  } else if ( b.equals( "ecirc" ) ) {  
    return inicio + "\u00ea" + fim;
  } else if ( b.equals( "Egrave" ) ) {  
    return inicio + "\u00c8" + fim;
  } else if ( b.equals( "egrave" ) ) {  
    return inicio + "\u00e8" + fim;
  } else if ( b.equals( "Iacute" ) ) {  
    return inicio + "\u00cd" + fim;
  } else if ( b.equals( "iacute" ) ) {  
    return inicio + "\u00ed" + fim;
  } else if ( b.equals( "Icirc" ) ) {  
    return inicio + "\u00ce" + fim;
  } else if ( b.equals( "icirc" ) ) {  
    return inicio + "\u00ee" + fim;
  } else if ( b.equals( "Igrave" ) ) {  
    return inicio + "\u00cc" + fim;
  } else if ( b.equals( "igrave" ) ) {  
    return inicio + "\u00ec" + fim;
  } else if ( b.equals( "Oacute" ) ) {  
    return inicio + "\u00d3" + fim;
  } else if ( b.equals( "oacute" ) ) {  
    return inicio + "\u00f3" + fim;
  } else if ( b.equals( "Ocirc" ) ) {  
    return inicio + "\u00d4" + fim;
  } else if ( b.equals( "ocirc" ) ) {  
    return inicio + "\u00f4" + fim;
  } else if ( b.equals( "Ograve" ) ) {  
    return inicio + "\u00d2" + fim;
  } else if ( b.equals( "ograve" ) ) {  
    return inicio + "\u00f2" + fim;
  } else if ( b.equals( "Otilde" ) ) {  
    return inicio + "\u00d5" + fim;
  } else if ( b.equals( "otilde" ) ) {  
    return inicio + "\u00f5" + fim;
  } else if ( b.equals( "Uacute" ) ) {  
    return inicio + "\u00da" + fim;
  } else if ( b.equals( "uacute" ) ) {  
    return inicio + "\u00fa" + fim;
  } else if ( b.equals( "Ucirc" ) ) {  
    return inicio + "\u00db" + fim;
  } else if ( b.equals( "ucirc" ) ) {  
    return inicio + "\u00fb" + fim;
  } else if ( b.equals( "Ugrave" ) ) {  
    return inicio + "\u00d9" + fim;
  } else if ( b.equals( "ugrave" ) ) {  
    return inicio + "\u00f9" + fim;
  } else if ( b.equals( "Ccedil" ) ) {  
    return inicio + "\u00c7" + fim;
  } else if ( b.equals( "ccedil" ) ) {  
    return inicio + "\u00e7" + fim;
  } else if ( b.equals( "Ntilde" ) ) {  
    return inicio + "\u00d1" + fim;
  } else if ( b.equals( "ntilde" ) ) {  
    return inicio + "\u00f1" + fim;
  } else if ( b.equals( "acute" ) ) {  
    return inicio + "`" + fim;
  } else if ( b.equals( "quot" ) ) {  
    return inicio + "`" + fim;
  } else if ( b.equals( "amp" ) ) {  
    return inicio + "e" + fim;
  } else if ( b.equals( "ordm" ) ) {  
    return inicio + "\u00ba" + fim;
  } else if ( b.equals( "uuml" ) ) {  
    return inicio + "u" + fim;
  } else if ( b.equals( "#39" ) ) {  
    return inicio + "" + fim;
  } else if ( b.equals( "Auml" ) ) {  
    return inicio + "A" + fim;
  } else if ( b.equals( "ouml" ) ) {  
    return inicio + "o" + fim;
  } else if ( b.equals( "nbsp" ) ) {  
    return inicio + "" + fim;
  } else if ( b.equals( "deg" ) ) {  
    return inicio + "\u00ba" + fim;
  } else { 
    println("ERRO no htmlAccent " + a + "!!!!" + b); 
    return "ERRO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" + b;
  }
}

public void runSendMessageChoreo(String a) {
  // Create the Choreo object using your Temboo session
  refreshtoken = "1/-iG1IN-lAXF5z5EcoB4cY7GD1RXnSQssq9M2tetjLe9IgOrJDtdun6zK6XiATCKT";

  SendMessage sendMessageChoreo = new SendMessage(session);

  // Set inputs
  sendMessageChoreo.setClientSecret("FeNTN_16sJDcLmwzRq1x9aqU");
  sendMessageChoreo.setMessageBody(a);
  sendMessageChoreo.setSubject("CrawlMarkt");
  sendMessageChoreo.setTo("brunobaring@gmail.com");
  sendMessageChoreo.setRefreshToken(refreshtoken);
  sendMessageChoreo.setFrom("brunobaring@gmail.com");
  sendMessageChoreo.setClientID("4328618275-3f18sm8ittu2dea3rbna98nbi62ivdb4.apps.googleusercontent.com");

  // Run the Choreo and store the results
  SendMessageResultSet sendMessageResults = sendMessageChoreo.run();

  // Print results
  println(sendMessageResults.getResponse());
  println(sendMessageResults.getNewAccessToken());
}
public void PaoDeAcucar() {
  counterTempoGPA = millis();

  String input[] = loadStrings("links_GPA.txt");
  fim = input.length;
  comeco = 0;
  // fim = 1;
  // comeco = 194;


  println("Crawl do Pao de Acucar: COMECOU!");
  log.println("Crawl do Pao de Acucar: COMECOU!");
  PrintWriter out2put = createWriter(path + dia + ":" + mes + ":" + ano + "/_MASTER_GPA_" + dia + ":" + mes + ":" + ano + ".txt");

  for ( int k = comeco; k < fim; k++ ) {
    int qtyPages = 1;
    String partialAddress = input[k].substring(0, input[k].indexOf(",")) + "?qt=36&p=";
    String category = input[k].substring(input[k].indexOf("/", 43) + 1, input[k].indexOf(","));
    print("_/,,/  : " + k + "/" + fim + " - " + category);
    log.print("_/,,/  : " + k + "/" + fim + " - " + category);

    out2put.println();
    out2put.print(category);
    for ( int j = 0; j <= qtyPages; j++ ) {
      print(" =>  pag " + j + " ...  ");
      log.print(" =>  pag " + j + " ...  ");
      wait(PApplet.parseInt(random(waitBottom, waitTop)*1000));
      String lines[] = loadStrings(partialAddress+j);

      for ( int i = 0; i < lines.length; i++) {


        //println(lines[i]);
        if ( match(lines[i], "Mostrando") != null) {
          int a = Integer.parseInt((trim(lines[i].substring(lines[i].indexOf("de ", 20) + 3, lines[i].indexOf(" produtos")))));
          if ( a % 36 == 0 ) {
            qtyPages = (a/36) - 1;
          } else { 
            qtyPages = a/36;
          }
        }
        //LINK DA FOTO
        if ( match(lines[i], "class=\"prdImagem img\">") != null) {
          out2put.println();
          //          println(lines[i]);
          int b = lines[i].indexOf("src=\"/img/uploads/1") + 19;
          int c = lines[i].indexOf("\" class=\"prdImagem img\"");
          if (b != -1 && c != -1) {
            String d = lines[i].substring(b, c);
            out2put.print(d + ",");
          }
        }

        //NOME DO PRODUTO
        if ( match(lines[i], "class=\"link\">") != null && match(lines[i], "</a></h3>") != null) {
          int b = lines[i].indexOf("class=\"link\">") + 13;
          String c = lines[i].substring(b, lines[i].length() - 9);

          if ( match(c, ",") != null) {
            c = substituiCharNaString(c, ',', '.');
          }

          while ( c.indexOf ("'") != -1 ) {
            c = substituiCharNaString(c, '\'', '\u00b4');
          }

          while ( c.indexOf (";") != -1 ) {
            c = htmlAccent(c);
          }

          counterProdutosCrawlGPA++;
          out2put.print(c + ",");
        }
        //PRECO
        if ( match(lines[i], "<span class=\"fromTo\">Por:</span>") != null ) {
          int b = lines[i].indexOf("class=\"value\">") + 14;
          String c = lines[i].substring(b, lines[i].indexOf("</span>", lines[i].length() - 10) );
          out2put.print(c);
        }
      }
    }

    println("Done!!!");
    log.println("Done!!!");
  }
  out2put.flush();
  out2put.close();

  println("Crawl do Pao de Acucar: ACABOU");
  log.println("Crawl do Pao de Acucar: ACABOU");
}

public void BD_PaoDeAcucar() {


  info prod = new info();

  String input2[]; 
  input2 = loadStrings(path + dia + ":" + mes + ":" + ano + "/_MASTER_GPA_" + dia + ":" + mes + ":" + ano + ".txt");

  //REMOVE DUPLICATAS
  println("Remover Duplicatas do Pao de Acucar: COMECOU");
  log.println("Remover Duplicatas do Pao de Acucar: COMECOU");
  for ( int i = 0; i < input2.length; i++ ) {
    if ( input2[i].indexOf(",") != -1 ) {
      String nameFix = "";
      nameFix = input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length()); //retira o link da imagem do input
      nameFix = nameFix.substring(0, nameFix.indexOf(",")); // separa nome do produto
      for ( int k = i+1; k < input2.length; k++ ) {
        if ( input2[k].indexOf(",") != -1 ) {
          String nameFix1 = "";
          nameFix1 = input2[k].substring(input2[k].indexOf(",") + 1, input2[k].length()); //retira o link da imagem do input
          nameFix1 = nameFix1.substring(0, nameFix1.indexOf(",")); // separa nome do produto
          if ( nameFix.equals(nameFix1) ) {
            counterDuplicatasGPA++;
            //              println(counterDuplicatasGPA + " " + nameFix);\
            input2[i] = "";
            k = input2.length;
          }
        }
      }
    }
  }
  println("Remover Duplicatas do Pao de Acucar: ACABOU");
  log.println("Remover Duplicatas do Pao de Acucar: ACABOU");

  pgsql = new PostgreSQL( this, host, database, user, pass ); 
  if ( pgsql.connect() ) {
    println("Inserir no Banco do Pao de Acucar: COMECOU");
    log.println("Inserir no Banco do Pao de Acucar: COMECOU");
    String category = "";
    for ( int i = 0; i < input2.length; i++ ) { 
      if ( !input2[i].equals("") ) {        
        prod.renew();
        if ( input2[i].indexOf(",") == -1) {
          category = input2[i].toLowerCase();
          pgsql.query( "INSERT INTO category(name, created_at) SELECT '" + category + "',current_timestamp WHERE NOT EXISTS (SELECT name FROM category where name = '" + category + "');" );
        } else if ( !input2[i].equals("") ) {        
          prod.category = category; //list[j].substring(0, list[j].length()-4);//define nome da categoria
          prod.imageLink = input2[i].substring(0, input2[i].indexOf(",")); //separa link da imagem
          input2[i] = input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length()); //retira o link da imagem do input
          if (input2[i].charAt(0) == '\"') { // se o nome tiver v\u00edrgula no meio (o nome fica separado por aspas quando tem virgula no meio)
            input2[i] = substituiCharNaString(input2[i], '\"', ' ');
            input2[i] = input2[i].substring(0, input2[i].indexOf(",")) + "." + input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length());
          }
          prod.name = input2[i].substring(0, input2[i].indexOf(",")).toLowerCase(); // separa nome do produto
          prod.price = properFloat(input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length())); //retira o nome do input e sobra o preco

          pgsql.query( "INSERT INTO product(name,created_at) SELECT '" + prod.name + "',current_timestamp WHERE NOT EXISTS (SELECT name FROM product WHERE name = '" + prod.name + "') RETURNING id;" );
          if ( pgsql.next() )
          {
            pgsql.query( "CREATE VIEW prod_ID_" + pgsql.getInt(1) + " AS SELECT * FROM register WHERE id_product = " + pgsql.getInt(1) + "; ");
          }
          pgsql.query( "INSERT INTO register(id_product,id_category,id_market,price,datedate,created_at,imagelink) VALUES((SELECT id FROM product WHERE name = '" + prod.name + "'),(SELECT id FROM category WHERE name = '" + prod.category + "'),2," + prod.price + ",current_date,current_timestamp,'" + prod.imageLink + "');" );
          counterProdutosBancoGPA++;
        }
        println("line: " + i + " \t" + prod.name);
      }
      wait(20);
    }
    println("Inserir no Banco do Pao de Acucar: ACABOU");
    log.println("Inserir no Banco do Pao de Acucar: ACABOU");
    pgsql.close();
    pgsql = null;
  }
  counterTempoGPA = millis() - counterTempoGPA;
  wait(wait);
}

public void dropDB() {
  pgsql = new PostgreSQL( this, host, database, user, pass );
  if ( pgsql.connect() )
  {
    pgsql.query( "SELECT max(id) FROM product;" );
    pgsql.next();
    int maxId = pgsql.getInt(1);

    for (int a = 1; a <= maxId; a++) {
      // query the number of entries in table "weather"
      pgsql.query( "drop view prod_id_" + a );
      wait(20);
      println( "drop view prod_id_" + a );
    }
    pgsql.query( "drop trigger minuscula_product_name_on_insert_trigger on product" );
    println( "drop trigger minuscula_product_name_on_insert_trigger on product" );
    pgsql.query( "drop function minuscula_product_name_on_insert()" );
    println( "drop function minuscula_product_name_on_insert()" );
    pgsql.query( "drop table \"market\" cascade" );
    println( "drop table \"market\" cascade" );
    pgsql.query( "drop table \"register\" cascade" );
    println( "drop table \"register\" cascade" );
    pgsql.query( "drop table \"category\" cascade" );
    println( "drop table \"category\" cascade" );
    pgsql.query( "drop table \"product\" cascade" );
    println( "drop table \"product\" cascade" );
    pgsql.query( "drop table \"search\" cascade" );
    println( "drop table \"product\" cascade" );


    pgsql.query( "CREATE TABLE \"market\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )");
    println( "CREATE TABLE \"market\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )" );
    pgsql.query( "CREATE TABLE \"product\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )");
    println( "CREATE TABLE \"product\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )" );
    pgsql.query( "CREATE TABLE \"category\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )");
    println( "CREATE TABLE \"category\" (\"id\" serial NOT NULL PRIMARY KEY,\"name\" varchar(200),\"created_at\" timestamp )" );
    pgsql.query( "CREATE TABLE \"register\" (\"id\" bigserial NOT NULL PRIMARY KEY,\"id_product\" integer NOT NULL REFERENCES product(\"id\"),\"id_category\" integer NOT NULL REFERENCES category(\"id\"),\"id_market\" integer NOT NULL REFERENCES market(\"id\"),\"price\" float,\"datedate\" date,\"created_at\" timestamp,\"imagelink\" varchar(200) )");
    println( "CREATE TABLE \"register\" (\"id\" bigserial NOT NULL PRIMARY KEY,\"id_product\" integer NOT NULL REFERENCES product(\"id\"),\"id_category\" integer NOT NULL REFERENCES category(\"id\"),\"id_market\" integer NOT NULL REFERENCES market(\"id\"),\"price\" float,\"datedate\" date,\"created_at\" timestamp,\"imagelink\" varchar(200) )" );
    pgsql.query( "CREATE TABLE \"search\" (\"id\" bigserial NOT NULL PRIMARY KEY,\"word\" varchar(200),\"qty_results\" integer,\"created_at\" timestamp )");
    println( "CREATE TABLE \"search\" (\"id\" bigserial NOT NULL PRIMARY KEY,\"word\" varchar(200),\"qty_results\" integer,\"created_at\" timestamp )" );
    pgsql.query( "INSERT INTO market(name, created_at) VALUES(\'zona sul\', current_timestamp)");
    println( "INSERT INTO market(name, created_at) VALUES(\'zona sul\', current_timestamp)" );
    pgsql.query( "INSERT INTO market(name, created_at) VALUES(\'pao de acucar\', current_timestamp)");
    println( "INSERT INTO market(name, created_at) VALUES(\'pao de acucar\', current_timestamp)" );
    pgsql.query( "INSERT INTO market(name, created_at) VALUES(\'extra\', current_timestamp)");
    println( "INSERT INTO market(name, created_at) VALUES(\'extra\', current_timestamp)");
    pgsql.query( "CREATE OR REPLACE FUNCTION minuscula_product_name_on_insert() RETURNS trigger AS $minuscula_product_name_on_insert$ BEGIN NEW.name = LOWER(NEW.name); RETURN NEW; END; $minuscula_product_name_on_insert$ LANGUAGE plpgsql; ");
    println( "CREATE OR REPLACE FUNCTION minuscula_product_name_on_insert() RETURNS trigger AS $minuscula_product_name_on_insert$ BEGIN NEW.name = LOWER(NEW.name); RETURN NEW; END; $minuscula_product_name_on_insert$ LANGUAGE plpgsql; " );
    pgsql.query( "CREATE TRIGGER minuscula_product_name_on_insert_trigger BEFORE INSERT OR UPDATE ON product FOR EACH ROW EXECUTE PROCEDURE minuscula_product_name_on_insert();");
    println( "CREATE TRIGGER minuscula_product_name_on_insert_trigger BEFORE INSERT OR UPDATE ON product FOR EACH ROW EXECUTE PROCEDURE minuscula_product_name_on_insert();");
  }
  pgsql = null;
}
/*
 
 drop table "market", "register", "category", "product" CASCADE;
 drop trigger minuscula_product_name_on_insert_trigger on product;
 drop function minuscula_product_name_on_insert();
 
 CREATE TABLE "market"
 (
 "id" serial NOT NULL PRIMARY KEY,
 "name" varchar(200),
 "created_at" timestamp
 );
 
 CREATE TABLE "product"
 (
 "id" serial NOT NULL PRIMARY KEY,
 "name" varchar(200),
 "created_at" timestamp
 );
 
 CREATE TABLE "category"
 (
 "id" serial NOT NULL PRIMARY KEY,
 "name" varchar(200),
 "created_at" timestamp
 );
 
 CREATE TABLE "register"
 (
 "id" bigserial NOT NULL PRIMARY KEY,
 "id_product" integer NOT NULL REFERENCES product("id"),
 "id_category" integer NOT NULL REFERENCES category("id"),
 "id_market" integer NOT NULL REFERENCES market("id"),
 "price" float,
 "datedate" date,
 "created_at" timestamp,
 "imagelink" varchar(200)
 );
 
 CREATE TABLE "search" 
 (
 "id" bigserial NOT NULL PRIMARY KEY,
 "word" varchar(200),
 "qty_results" integer,
 "created_at" timestamp
 );
 
 INSERT INTO market(name, created_at) 
 VALUES('zona sul', current_timestamp);
 INSERT INTO market(name, created_at) 
 VALUES('pao de acucar', current_timestamp);
 INSERT INTO market(name, created_at) 
 VALUES('extra', current_timestamp);
 

 CREATE OR REPLACE FUNCTION minuscula_product_name_on_insert() RETURNS trigger AS $minuscula_product_name_on_insert$
 BEGIN        
 NEW.name = LOWER(NEW.name);
 RETURN NEW;
 END;
 $minuscula_product_name_on_insert$ LANGUAGE plpgsql;
 
 CREATE TRIGGER minuscula_product_name_on_insert_trigger BEFORE INSERT OR UPDATE ON product
 FOR EACH ROW EXECUTE PROCEDURE minuscula_product_name_on_insert();
 
 INSERT INTO product (name, created_at) VALUES ('LOWERCASE ME', current_timestamp);
 
 SELECT max(id) FROM product;
 
 
 
 
 
 INSERT INTO product(id_market,name, created_at) 
 SELECT 1,'manteiga',current_timestamp
 WHERE NOT EXISTS(
 SELECT name FROM product where name = 'manteiga')
 RETURNING id;
 
 INSERT INTO category(name, created_at) 
 SELECT 'cervejas',current_timestamp
 WHERE NOT EXISTS(
 SELECT name FROM category where name = 'cervejas');
 
 INSERT INTO register(id_product,id_category,price,datedate,created_at,imagelink)
 VALUES(
 (SELECT id FROM product WHERE name = 'manteiga'),
 (SELECT id FROM category WHERE name = 'cervejas'),
 3.2,current_date,current_timestamp,'http://www...');
 
 
 SELECT * 
 FROM register 
 WHERE datedate 
 BETWEEN '2015-09-09' 
 AND '2015-09-09';
 
 
 SELECT * 
 FROM register 
 WHERE id_product 
 IN (SELECT id 
 FROM product 
 WHERE id_market = 2);
 
 */
public void ZonaSul() {
  counterTempoZS = millis();
  
  String input[] = loadStrings("links_ZS.txt");
  fim = input.length;
  comeco = 0;
  // fim = 1;
  // comeco = 160;

  pgsql = new PostgreSQL( this, host, database, user, pass );

  println("Crawl do Zona Sul: COMECOU");
  log.println("Crawl do Zona Sul: COMECOU");
  PrintWriter out2put = createWriter(path + dia + ":" + mes + ":" + ano + "/_MASTER_ZS_" + dia + ":" + mes + ":" + ano + ".txt");


  for ( int k = comeco; k < fim; k++ ) {
    int qtyPages = 1;
    String partialAddress = input[k].substring(0, input[k].indexOf(",")) + "?Pagina=";
    String category = input[k].substring(input[k].indexOf("--45/") + 5, input[k].indexOf("--", input[k].indexOf("45/")));

    print("_/,,/  : " + k + "/" + fim + " - " + category);
    log.print("_/,,/  : " + k + "/" + fim + " - " + category);


    out2put.println(category);
    for ( int j = 1; j <= qtyPages; j++ ) {
      print(" =>  pag " + j + " ...  ");
      log.print(" =>  pag " + j + " ...  ");
      wait(PApplet.parseInt(random(waitBottom, waitTop)*1000));
      String lines[] = loadStrings(partialAddress+j);

      for ( int i = 0; i < lines.length; i++) {


        if ( match(lines[i], "encontrados") != null) {
          if ( lines[i].charAt(lines[i].length() - 15) == ' ') {
            qtyPages = 1 + ((Integer.parseInt(trim(lines[i].substring(lines[i].length()-15, lines[i].length()-12))))/45);
          } else if ( lines[i].charAt(lines[i].length() - 16) == ' ') {
            qtyPages = 1 + ((Integer.parseInt(trim(lines[i].substring(lines[i].length()-16, lines[i].length()-12))))/45);
          }
        }
        //LINK DA FOTO
        if ( match(lines[i], "mg_thumb_list") != null) {
          int b = lines[i].indexOf("imgSrc80=\"");
          int c = lines[i].indexOf("imgSrc160=\"");
          if (b != -1 && c != -1) {
            String d = lines[i].substring(b + 59, c - 2);
            out2put.print(d + ",");
          }
        }

        //NOME DO PRODUTO
        if ( match(lines[i], "\"prod_info\"") != null && match(lines[i+1], "AreaLateral") == null) {
          int b = lines[i+1].indexOf("title=\"");
          String c = lines[i+1].substring(b + 7, lines[i+1].length());
          String d = "";
          if (c.indexOf("\" href") == -1) {
            d = c;
          } else {
            d = c.substring(0, c.indexOf("\" href"));
          }

          if ( match(d, ",") != null) {
            d = substituiCharNaString(d, ',', '.');
          }

          while ( d.indexOf ("'") != -1 ) {
            d = substituiCharNaString(d, '\'', '\u00b4');
          }


          while ( d.indexOf (";") != -1 ) {
            d = htmlAccent(d);
          }

          counterProdutosCrawlZS++;
          out2put.print(d + ",");
        }
        //PRECO
        if ( match(lines[i], "\"preco\"") != null && match(lines[i-2], "AreaLateral") == null) {
          int b = lines[i+1].indexOf("R$ ");
          String c = lines[i+1].substring(b + 3, lines[i+1].indexOf(",", b) + 3);
          out2put.print(c);
          if (!c.equals("")) {
            out2put.println();
          }
        } else if ( match(lines[i], "\"preco_por") != null ) {
          int b = lines[i+2].indexOf("R$ ");
          String c = lines[i+2].substring(b + 3, lines[i+2].indexOf(",", b) + 3);
          out2put.print(c);
          if (!c.equals("")) {
            out2put.println();
          }
        }
      }
    }


    println("Done!!!");
    log.println("Done!!!");
  }
  out2put.flush();
  out2put.close();

  println("Crawl do Zona Sul: ACABOU");
  log.println("Crawl do Zona Sul: ACABOU");
}



public void BD_ZonaSul() {


  info prod = new info();

  String input2[]; 
  input2 = loadStrings(path + dia + ":" + mes + ":" + ano + "/_MASTER_ZS_" + dia + ":" + mes + ":" + ano + ".txt");

  //REMOVE DUPLICATAS
  println("Remover Duplicatas do Zona Sul: COMECOU");
  log.println("Remover Duplicatas do Zona Sul: COMECOU");
  for ( int i = 0; i < input2.length; i++ ) {
    if ( input2[i].indexOf(",") != -1 ) {
      String nameFix = "";
      nameFix = input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length()); //retira o link da imagem do input
      nameFix = nameFix.substring(0, nameFix.indexOf(",")); // separa nome do produto
      for ( int k = i+1; k < input2.length; k++ ) {
        if ( input2[k].indexOf(",") != -1 ) {
          String nameFix1 = "";
          nameFix1 = input2[k].substring(input2[k].indexOf(",") + 1, input2[k].length()); //retira o link da imagem do input
          nameFix1 = nameFix1.substring(0, nameFix1.indexOf(",")); // separa nome do produto
          if ( nameFix.equals(nameFix1) ) {
            counterDuplicatasZS++;
            //              println(counterDuplicatasZS + " " + nameFix);
            input2[i] = "";
            k = input2.length;
          }
        }
      }
    }
  }
  println("Remover Duplicatas do Zona Sul: ACABOU");
  log.println("Remover Duplicatas do Zona Sul: ACABOU");

  pgsql = new PostgreSQL( this, host, database, user, pass );
  if ( pgsql.connect() ) {
    println("Inserir no Banco do Zona Sul: COMECOU");
    log.println("Inserir no Banco do Zona Sul: COMECOU");
    String category = "";
    for ( int i = 0; i < input2.length; i++ ) {
      if ( !input2[i].equals("") ) {
        prod.renew();
        if ( input2[i].indexOf(",") == -1 ) {
          category = input2[i].toLowerCase();
          pgsql.query( "INSERT INTO category(name, created_at) SELECT '" + category + "',current_timestamp WHERE NOT EXISTS (SELECT name FROM category where name = '" + category + "');" );
        } else if ( !input2[i].equals("") ) {        
          prod.category = category; //list[j].substring(0, list[j].length()-4);//define nome da categoria
          prod.imageLink = input2[i].substring(0, input2[i].indexOf(",")); //separa link da imagem
          input2[i] = input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length()); //retira o link da imagem do input
          if (input2[i].charAt(0) == '\"') { // se o nome tiver v\u00edrgula no meio (o nome fica separado por aspas quando tem virgula no meio)
            input2[i] = substituiCharNaString(input2[i], '\"', ' ');
            input2[i] = input2[i].substring(0, input2[i].indexOf(",")) + "." + input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length());
          }
          prod.name = input2[i].substring(0, input2[i].indexOf(",")).toLowerCase(); // separa nome do produto
          prod.price = properFloat(input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length())); //retira o nome do input e sobra o preco

          pgsql.query( "INSERT INTO product(name,created_at) SELECT '" + prod.name + "',current_timestamp WHERE NOT EXISTS (SELECT name FROM product WHERE name = '" + prod.name + "') RETURNING id;" );
          if ( pgsql.next() )
          {
            pgsql.query( "CREATE VIEW prod_ID_" + pgsql.getInt(1) + " AS SELECT * FROM register WHERE id_product = " + pgsql.getInt(1) + "; ");
          }
          pgsql.query( "INSERT INTO register(id_product,id_category,id_market,price,datedate,created_at,imagelink) VALUES((SELECT id FROM product WHERE name = '" + prod.name + "'),(SELECT id FROM category WHERE name = '" + prod.category + "'),1," + prod.price + ",current_date,current_timestamp,'" + prod.imageLink + "');" );
          counterProdutosBancoZS++;
        }
        println("line: " + i + " \t" + prod.name);
      }
      wait(20);
    }
    println("Inserir no Banco do Zona Sul: ACABOU");
    log.println("Inserir no Banco do Zona Sul: ACABOU");
    pgsql.close();
    pgsql = null;
  }
  counterTempoZS = millis() - counterTempoZS;
  wait(wait);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CrawlMarkt" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
