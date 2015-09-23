void ZonaSul() {
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
    String category = input[k].substring(input[k].indexOf("--45/") + 5, input[k].indexOf("--", input[k].indexOf("45/"))).toLowerCase();

    print("_/,,/  : " + k + "/" + fim + " - " + category);
    log.print("_/,,/  : " + k + "/" + fim + " - " + category);


    out2put.println(category);
    for ( int j = 1; j <= qtyPages; j++ ) {
      print(" =>  pag " + j + " ...  ");
      log.print(" =>  pag " + j + " ...  ");
      wait(int(random(waitBottom, waitTop)*1000));
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
            out2put.print(trim(d) + ",");
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
            d = substituiCharNaString(d, '\'', '´');
          }


          while ( d.indexOf (";") != -1 ) {
            d = htmlAccent(d);
          }

          counterProdutosCrawlZS++;
          out2put.print(trim(d).toLowerCase() + ",");
        }
        //PRECO
        if ( lines[i].indexOf("prod_preco rebaixa") != -1 ) {
          out2put.print(trim(lines[i+8].substring(lines[i+8].indexOf("R$") + 2, lines[i+8].indexOf("</ins>"))));
          out2put.println(trim("," + lines[i+4].substring(lines[i+4].indexOf("R$") + 2, lines[i+4].indexOf("</del>"))));
        }

        if ( lines[i].indexOf("\"preco\">") != -1 && lines[i-2].indexOf("AreaLateral") == -1 ) {
          out2put.println(trim(lines[i+1].substring(lines[i+1].indexOf("R$") + 2, lines[i+1].indexOf(",") + 3)));
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



void BD_ZonaSul() {


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
          pgsql.query( "INSERT INTO register(id_product,id_category,id_market,price,datedate,created_at,imagelink) VALUES((SELECT id FROM product WHERE name = '" + prod.name + "'),(SELECT id FROM category WHERE name = '" + prod.category + "'),1," + prod.price + ",current_date,current_timestamp,'" + prod.imageLink + "');" );
          counterProdutosBancoZS++;
        }
        println("line: " + i + " \t" + prod.name);
      }
      wait(waitDB);
    }
    println("Inserir no Banco do Zona Sul: ACABOU");
    log.println("Inserir no Banco do Zona Sul: ACABOU");
    pgsql.close();
    pgsql = null;
  }
  counterTempoZS = millis() - counterTempoZS;
  wait(wait);
}
