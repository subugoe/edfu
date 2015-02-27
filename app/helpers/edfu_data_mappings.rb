module EdfuDataMappings

  def dezimal_nach_roemisch (dezimal)

    hsh = {
        1 => 'I',
        2 => 'II',
        3 => 'III',
        4 => 'IV',
        5 => 'V',
        6 => 'VI',
        7 => 'VII',
        8 => 'VIII'
    }

    begin
      return hsh[dezimal.to_i]
    rescue NoMethodError
      return nil
    end

  end

  def roemisch_nach_dezimal (roemisch)

    hsh = {
        'I'    => 1,
        'II'   => 2,
        'III'  => 3,
        'IV'   => 4,
        'V'    => 5,
        'VI'   => 6,
        'VII'  => 7,
        'VIII' => 8
    }

    begin
      return hsh[roemisch]
    rescue NoMethodError
      return nil
    end

  end


  def formular_literatur_relation_hash
    {
        1  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        2  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        3  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        4  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 2, 'detail' => '10 (38.), u. n. 40*'}],
        5  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        6  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 4, 'detail' => '309, n. 11'},
               {'literatur_beschreibung_key' => 5, 'detail' => '515, n. 135'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        7  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        8  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        9  => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        10 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        11 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'},
               {'literatur_beschreibung_key' => 3, 'detail' => '145, n. 676'}],
        12 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        13 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        14 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        15 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        16 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}],
        17 => [{'literatur_beschreibung_key' => 1, 'detail' => '14, n. 51'}]
    }
  end

  def literatur_beschreibung_hash
    {
        1 => 'Bedier, in: GM 162, 1998',
        2 => 'Budde/Kurth, in: EB 4, 1994',
        3 => 'Labrique, Stylistique',
        4 => 'Aufrère, L’univers minéral I',
        5 => 'Aufrère, L’univers minéral II'
    }
  end


  def photoTypDict
    {
        'alt'                   => {'uid' => 0, 'name' => 'SW', 'jahr' => 1999},
        'D03'                   => {'uid' => 1, 'name' => '2003', 'jahr' => 2003},
        'D05'                   => {'uid' => 2, 'name' => '2005', 'jahr' => 2005},
        'e'                     => {'uid' => 3, 'name' => 'e', 'jahr' => 1900},
        'G'                     => {'uid' => 4, 'name' => 'G', 'jahr' => 1950},
        'e-o'                   => {'uid' => 5, 'name' => 'e-o', 'jahr' => 1960},
        'Labrique, Stylistique' => {'uid' => 6, 'name' => 'Labrique, Stylistique', 'jahr' => 1912},
        'E. XIII'               => {'uid' => 7, 'name' => 'Edfou XIII', 'jahr' => 1913},
        'E. XIV'                => {'uid' => 8, 'name' => 'Edfou XIV', 'jahr' => 1914},
    }
  end

  def banddict(bandId, element)

    bandDict = {
        1 => {'uid'        => 1, 'nummer' => 1, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou I, 1892.',
              'tempel_uid' => 0},
        2 => {'uid'        => 2, 'nummer' => 2, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou II, 1897.',
              'tempel_uid' => 0},
        3 => {'uid'        => 3, 'nummer' => 3, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou III, 1928.',
              'tempel_uid' => 0},
        4 => {'uid'        => 4, 'nummer' => 4, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou IV, 1929.',
              'tempel_uid' => 0},
        5 => {'uid'        => 5, 'nummer' => 5, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou V, 1930.',
              'tempel_uid' => 0},
        6 => {'uid'        => 6, 'nummer' => 6, 'freigegeben' => false, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou VI, 1931.',
              'tempel_uid' => 0},
        7 => {'uid'        => 7, 'nummer' => 7, 'freigegeben' => true, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou VII, 1932.',
              'tempel_uid' => 0},
        8 => {'uid'        => 8, 'nummer' => 8, 'freigegeben' => true, 'literatur' => 'Chassinat, Émile; Le Temple d’Edfou VIII, 1933.',
              'tempel_uid' => 0}
    }

    begin
      return bandDict[bandId][element]
    rescue NoMethodError
      return nil
    end

  end

  # def berlin
  #   [
  #       {
  #           'uid'         => 0,
  #           'band'        => 0,
  #           'seite_start' => 0,
  #           'seite_stop'  => 0,
  #           'zeile_start' => 0,
  #           'zeile_stop'  => 0,
  #           'notiz'       => nil
  #       }
  #   ]
  # end

end
