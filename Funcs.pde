
void inita() {

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
    if ( market.equals("sendEmail") && action.indexOf("y") != -1 )
      sendEmail = true;
    if ( market.equals("comeco") )
      comeco = Integer.parseInt(action);    
    if ( market.equals("fim") )
      fim = Integer.parseInt(action);
    if ( market.equals("wait") )
      wait = Integer.parseInt(action);
    if ( market.equals("waitDB") )
      waitDB = Integer.parseInt(action);
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


void wait( int tempo) {
  //  print(tempo/1000 + "s  ");
  int aux=millis();
  while ( millis ()-aux<tempo) {
  }
}


void displaySum() {

  println( "#\t\t O Programa encerrou em: \t" + day() + "/" + month() + "/" + year() + " às " + hour() + ":" + minute() + ":" + second() ); 

  println("\tZS\tGPA\tExtra");
  println("Crawl\t" + counterProdutosCrawlZS + "\t" + counterProdutosCrawlGPA + "\t" + counterProdutosCrawlExtra);
  println("Banco\t" + counterProdutosBancoZS + "\t" + counterProdutosBancoGPA + "\t" + counterProdutosBancoExtra);
  println("Duplicatas\t" + counterDuplicatasZS + "\t" + counterDuplicatasGPA + "\t" + counterDuplicatasExtra);
  println("Ok?\t" + (counterProdutosCrawlZS - counterDuplicatasZS - counterProdutosBancoZS) + "\t" + (counterProdutosCrawlGPA - counterDuplicatasGPA - counterProdutosBancoGPA) + "\t" + (counterProdutosCrawlExtra - counterDuplicatasExtra - counterProdutosBancoExtra));
  println("Tempo\t" + counterTempoZS/60000 + "\t" + counterTempoGPA/60000 + "\t" + counterTempoExtra/60000);

  println("\nTempo Total: " + ( (counterTempoZS/60000) + (counterTempoGPA/60000) + (counterTempoExtra/60000) ));
  println("\nBanco Total: " + ( (counterProdutosCrawlZS - counterDuplicatasZS - counterProdutosBancoZS) + (counterProdutosCrawlGPA - counterDuplicatasGPA - counterProdutosBancoGPA) + (counterProdutosCrawlExtra - counterDuplicatasExtra - counterProdutosBancoExtra) ));


  //////////////////////////    LOG LOG LOG LOG LOG LOG LOG    //////////////////////////////
  log.println( "#\t\t O Programa encerrou em: \t" + day() + "/" + month() + "/" + year() + " às " + hour() + ":" + minute() + ":" + second() ); 

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

String prepareEmailMessage() {

  String emailMessage = ""; 

  emailMessage += "#\t\t O Programa encerrou em: \n" + day() + "/" + month() + "/" + year() + " às " + hour() + ":" + minute() + ":" + second() ; 

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


float properFloat(String a) {
  if (a.equals("")) {
    return 0.0;
  } else {
    String unidades = a.substring(0, a.indexOf(","));
    if ( unidades.indexOf(".") != -1 ) {
      unidades = unidades.substring(0, unidades.indexOf(".")) + unidades.substring(unidades.indexOf(".") + 1, unidades.length());
    }
    return float(unidades + "." + a.substring(a.indexOf(",") + 1, a.length()));
  }
}

String substituiCharNaString(String a, char c1, char c2) {
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
  float  price = 0.0;
  float  deprice = 0.0;
  String name = "";
  String date = "";
  String category = "";
  info() {
  }

  void renew() {
    imageLink = "";
    price = 0.0;
    deprice = 0.0;
    name = "";
    date = "";
    category = "";
  }
}



String htmlAccent(String a) {

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
    return inicio + "Á" + fim;
  } else if ( b.equals( "aacute" ) ) {  
    return inicio + "a" + fim;
  } else if ( b.equals( "Acirc" ) ) {  
    return inicio + "Â" + fim;
  } else if ( b.equals( "acirc" ) ) {  
    return inicio + "â" + fim;
  } else if ( b.equals( "Agrave" ) ) {  
    return inicio + "Á" + fim;
  } else if ( b.equals( "agrave" ) ) {  
    return inicio + "á" + fim;
  } else if ( b.equals( "Atilde" ) ) {  
    return inicio + "Ã" + fim;
  } else if ( b.equals( "atilde" ) ) {  
    return inicio + "ã" + fim;
  } else if ( b.equals( "Eacute" ) ) {  
    return inicio + "É" + fim;
  } else if ( b.equals( "eacute" ) ) {  
    return inicio + "é" + fim;
  } else if ( b.equals( "Ecirc" ) ) {  
    return inicio + "Ê" + fim;
  } else if ( b.equals( "ecirc" ) ) {  
    return inicio + "ê" + fim;
  } else if ( b.equals( "Egrave" ) ) {  
    return inicio + "È" + fim;
  } else if ( b.equals( "egrave" ) ) {  
    return inicio + "è" + fim;
  } else if ( b.equals( "Iacute" ) ) {  
    return inicio + "Í" + fim;
  } else if ( b.equals( "iacute" ) ) {  
    return inicio + "í" + fim;
  } else if ( b.equals( "Icirc" ) ) {  
    return inicio + "Î" + fim;
  } else if ( b.equals( "icirc" ) ) {  
    return inicio + "î" + fim;
  } else if ( b.equals( "Igrave" ) ) {  
    return inicio + "Ì" + fim;
  } else if ( b.equals( "igrave" ) ) {  
    return inicio + "ì" + fim;
  } else if ( b.equals( "Oacute" ) ) {  
    return inicio + "Ó" + fim;
  } else if ( b.equals( "oacute" ) ) {  
    return inicio + "ó" + fim;
  } else if ( b.equals( "Ocirc" ) ) {  
    return inicio + "Ô" + fim;
  } else if ( b.equals( "ocirc" ) ) {  
    return inicio + "ô" + fim;
  } else if ( b.equals( "Ograve" ) ) {  
    return inicio + "Ò" + fim;
  } else if ( b.equals( "ograve" ) ) {  
    return inicio + "ò" + fim;
  } else if ( b.equals( "Otilde" ) ) {  
    return inicio + "Õ" + fim;
  } else if ( b.equals( "otilde" ) ) {  
    return inicio + "õ" + fim;
  } else if ( b.equals( "Uacute" ) ) {  
    return inicio + "Ú" + fim;
  } else if ( b.equals( "uacute" ) ) {  
    return inicio + "ú" + fim;
  } else if ( b.equals( "Ucirc" ) ) {  
    return inicio + "Û" + fim;
  } else if ( b.equals( "ucirc" ) ) {  
    return inicio + "û" + fim;
  } else if ( b.equals( "Ugrave" ) ) {  
    return inicio + "Ù" + fim;
  } else if ( b.equals( "ugrave" ) ) {  
    return inicio + "ù" + fim;
  } else if ( b.equals( "Ccedil" ) ) {  
    return inicio + "Ç" + fim;
  } else if ( b.equals( "ccedil" ) ) {  
    return inicio + "ç" + fim;
  } else if ( b.equals( "Ntilde" ) ) {  
    return inicio + "Ñ" + fim;
  } else if ( b.equals( "ntilde" ) ) {  
    return inicio + "ñ" + fim;
  } else if ( b.equals( "acute" ) ) {  
    return inicio + "`" + fim;
  } else if ( b.equals( "quot" ) ) {  
    return inicio + "`" + fim;
  } else if ( b.equals( "amp" ) ) {  
    return inicio + "e" + fim;
  } else if ( b.equals( "ordm" ) ) {  
    return inicio + "º" + fim;
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
    return inicio + "º" + fim;
  } else { 
    println("ERRO no htmlAccent " + a + "!!!!" + b); 
    return "ERRO!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" + b;
  }
}

void runSendMessageChoreo(String a) {
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
