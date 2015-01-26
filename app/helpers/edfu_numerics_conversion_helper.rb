module EdfuNumericsConversionHelper

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
        'I' => 1,
        'II' => 2,
        'III' => 3,
        'IV' => 4,
        'V' => 5,
        'VI' => 6,
        'VII' => 7,
        'VIII' => 8
    }

    begin
      return hsh[roemisch]
    rescue NoMethodError
      return nil
    end

  end
end
