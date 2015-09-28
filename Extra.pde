void Extra() {
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
    String partialAddress = input[k].substring(0, input[k].indexOf(",")) + "?sort=&rows=36&q=&offset=";
    String category = input[k].substring(input[k].indexOf("/", 53) + 1, input[k].indexOf(",")).toLowerCase();

    print("_/,,/  : " + k + "/" + fim + " - " + category);
    log.print("_/,,/  : " + k + "/" + fim + " - " + category);


    out2put.println(category);
    // println(category);
    for ( int j = 1; j <= qtyPages; j++ ) {
      print(" =>  pag " + j + " ...  ");
      log.print(" =>  pag " + j + " ...  ");
      wait(int(random(waitBottom, waitTop)*1000));
      String lines[];

      String fullAddress = partialAddress;
      if ( j >= 2 ) {
        fullAddress = partialAddress + (j-1)*36;
      }





      try {
        lines = loadStrings(fullAddress);
      }
      catch (Exception e) {
        println("deu aquela treta Exception");
        log.println("deu aquela treta Exception");
        log.flush();
        log.close();
        log = null;
        log = createWriter(path + dia + ":" + mes + ":" + ano + "/_LOGEXTRA" + random(1,200) + "_" + dia + ":" + mes + ":" + ano + ".txt");
        wait(20 * 60 * 1000);    
        lines = loadStrings(fullAddress);
        e.printStackTrace();
      }


      for ( int i = 0; i < lines.length; i++) {


        if ( match(lines[i], "Produtos encontrados:") != null) {
          qtyPages = 1 + ((Integer.parseInt(trim(lines[i].substring(lines[i].indexOf("<span>") + 6, lines[i].indexOf("</span>")))))/36);
        }
        //LINK DA FOTO
        if ( match(lines[i], "prdImagem") != null) {
          int b = lines[i].indexOf("src=\"");
          int c = lines[i].indexOf("\" class=");
          if (b != -1 && c != -1) {
            String d = lines[i].substring(b + 5 + 4, c);
            out2put.print(trim(d) + ",");
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
            d = substituiCharNaString(d, '\'', '´');
          }

          while ( d.indexOf (";") != -1 ) {
            d = htmlAccent(d);
          }

          counterProdutosCrawlExtra++;
          out2put.print(trim(d).toLowerCase() + ",");
          // println(d);
        }
        //PRECO
        if ( match(lines[i], "prdPreco prdPrices") != null) {
          // println(lines[i]);
          int b = lines[i].indexOf("</em><strong>");
          String c = lines[i].substring(b + 13, lines[i].indexOf("</strong></span>"));
          out2put.print(trim(c));
          if ( lines[i].indexOf("priceCuted") != -1 ) {
            out2put.print("," + trim(lines[i].substring(lines[i].indexOf("class=\"priceCuted\">R$ ") + 22, lines[i].indexOf("</span></span><span class="))));
          }
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



void BD_Extra() {


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
          // if (nameFix1.indexOf("´") != -1 ) {

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
      // try { 
      if ( !input2[i].equals("") ) {
        prod.renew();
        if ( input2[i].indexOf(",") == -1 ) {
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
          input2[i] = input2[i].substring(input2[i].indexOf(",") + 1, input2[i].length()); //retira o nome do input
          if ( input2[i].indexOf(",", input2[i].indexOf(",") + 1) != -1 ) {
            prod.price = properFloat(trim(input2[i].substring(0, input2[i].indexOf(",", input2[i].indexOf(",") + 1)))); //retira o nome do input e sobra o preco
            prod.deprice = properFloat(trim(input2[i].substring( nf(prod.price, 1, 2).length()+1, input2[i].length())));
          } else {
            prod.price = properFloat(input2[i].substring(0, input2[i].length())); //retira o nome do input e sobra o preco
          }
          pgsql.query( "INSERT INTO product(name,created_at) SELECT '" + prod.name + "',current_timestamp WHERE NOT EXISTS (SELECT name FROM product WHERE name = '" + prod.name + "') RETURNING id;" );
          if ( pgsql.next() )
          {
            pgsql.query( "CREATE VIEW prod_ID_" + pgsql.getInt(1) + " AS SELECT * FROM register WHERE id_product = " + pgsql.getInt(1) + "; ");
          }
          pgsql.query( "INSERT INTO register(id_product,id_category,id_market,price,deprice,datedate,created_at,imagelink) VALUES((SELECT id FROM product WHERE name = '" + prod.name + "'),(SELECT id FROM category WHERE name = '" + prod.category + "'),3," + prod.price + "," + prod.deprice + ",current_date,current_timestamp,'" + prod.imageLink + "');" );
          counterProdutosBancoExtra++;
        }
        println("line: " + i + " \t" + prod.name);
      }
      // }
      // catch(Exception e) {
      //   println("Exception no BANCO EXTRA. Esperar " + waitExceptionDB + " minutos.");
      //   log.println("Exception no BANCO EXTRA. Esperar " + waitExceptionDB + " minutos.");
      //   wait(waitExceptionDB);
      //   i--;
      // }
      wait(waitDB);
    }
    println("Inserir no Banco do Extra: ACABOU");
    log.println("Inserir no Banco do Extra: ACABOU");
    pgsql.close();
    pgsql = null;
  }
  counterTempoExtra = millis() - counterTempoExtra;
  wait(wait);
}
