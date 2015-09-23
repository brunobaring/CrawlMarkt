void PaoDeAcucar() {
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
    String category = input[k].substring(input[k].indexOf("/", 43) + 1, input[k].indexOf(",")).toLowerCase();
    print("_/,,/  : " + k + "/" + fim + " - " + category);
    log.print("_/,,/  : " + k + "/" + fim + " - " + category);

    out2put.println();
    out2put.print(category);
    for ( int j = 0; j <= qtyPages; j++ ) {
      print(" =>  pag " + j + " ...  ");
      log.print(" =>  pag " + j + " ...  ");
      wait(int(random(waitBottom, waitTop)*1000));
      String lines[] = loadStrings(partialAddress+j);

      String lineCrawl = "";
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
            lineCrawl += trim(d) + ",";
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
            c = substituiCharNaString(c, '\'', '´');
          }

          while ( c.indexOf (";") != -1 ) {
            c = htmlAccent(c);
          }

          counterProdutosCrawlGPA++;
          lineCrawl += trim(c).toLowerCase() + ",";
        }
        //PRECO
        if ( match(lines[i], "<span class=\"fromTo\">Por:</span>") != null ) {
          int b = lines[i].indexOf("class=\"value\">") + 14;
          String c = lines[i].substring(b, lines[i].indexOf("</span>", lines[i].length() - 10) );
          lineCrawl += trim(c); 
          if ( lines[i-5].indexOf("De:") != -1) {
            lineCrawl += "," + lines[i-5].substring(lines[i-5].indexOf("\"value\">") + 8, lines[i-5].indexOf("</span>", lines[i-5].length()-10));
          }
          out2put.println(lineCrawl);
          lineCrawl = "";
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

void BD_PaoDeAcucar() {


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
          if (input2[i].charAt(0) == '\"') { // se o nome tiver vírgula no meio (o nome fica separado por aspas quando tem virgula no meio)
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
      wait(waitDB);
    }
    println("Inserir no Banco do Pao de Acucar: ACABOU");
    log.println("Inserir no Banco do Pao de Acucar: ACABOU");
    pgsql.close();
    pgsql = null;
  }
  counterTempoGPA = millis() - counterTempoGPA;
  wait(wait);
}
