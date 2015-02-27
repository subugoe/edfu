module StellenHelper


  def self.banddict(bandId, element)

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

end
