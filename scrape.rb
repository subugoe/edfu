require 'yaml'
require 'nokogiri'
require 'csv'

class Scrape

  def initialize

    file = File.join('config', 'edfu_mappings.yml')

    config = (YAML.load(File.open(file)))['defaults']

    @numbertail = config['NUMBERTAIL']

    config['rooms'].each { |key, room|

      if room != nil

        if room.has_key? 'cut'
          cut = room['cut']
        else
          cut = false
        end

        data = run(room, config['lists'])
        createCsv(data, room['fileName'])

      end
    }

  end


  def createCsv(data, filename)

    CSV.open(filename, 'w', :col_sep => ';') do |file|

      # if (!file)
      #   return false
      # end

      if (arrayIsAssoc(data[0]))

        captions = data[0].keys

        #unshift(data, captions)

        file << captions

      end

      data.each do |fields|

         file << fields.values

      end

      #file.close
      return true

    end

  end


  def arrayIsAssoc(array)

    if (array.class == Hash)
      return true
    end

    return false

  end


# Main program for scraping images and
# Fetches an URL and the nested image maps and areas or areas from a gif-file.
# Relevant informations from the areas are read and calculated.
#
# :call-seq:
#   room  ->  an array with room informations
#   lists ->  an array of lists with specific exceptions
# return the data for each area
  def run(room, lists)

    type = File.extname(room['url']).sub('.', '')
    i    = 0
    go   = true
    data = Array.new


    if (type == 'html')
      site = Nokogiri::HTML(open(room['url']))

      href = Array.new

      imageMaps = checkForImageMaps(site)
    end


    if (type == 'gif')

      # todo: gif not yet implemented
      # areas = findAreasFromImage(room['url'], array(2, 0), 1, room['cut'])
      # if (isset(room['onlyWhite']))
      #   #only white areas:
      #   areas = findAreasFromImage(room['url'], array(0), 1, room['cut'])
      # end

    end


    if (type == 'gif' || areas = checkForAreas(site))

      areas.each do |area|

        # todo: gif processing
        if (type == 'gif' || area.attr('href'))

          if (type == 'html')
            # todo
            # (.*) - Edfou (.*),.*p. (.*)
            # (.*) - Edfou (\d*), p. (\d*), \(pl. (\d*)\)
            #

            description = ''
            volume      = ''
            page        = ''
            plate       = ''

            title = area.attr('title')
            if title == nil || title == ''
              # todo uncomment if realized as controller
              # logger.error "\t[ERROR]  [SCRAPE] title is nil for area element: #{area} in #{room['url']}"
              puts "\t[ERROR]  [SCRAPE] title is nil for area element: #{area} in #{room['url']}"
            else
              parts       = area.attr('title').split("-")
              description = parts[0].strip if parts[0] != nil

              if parts[1] == nil || parts[1].strip == ''
                puts "\t[ERROR]  [SCRAPE] no volume, page and plate info in title for area element: #{area} in #{room['url']}"
              else
                p      = parts[1].split(',') if parts[1] != nil
                volume = p[0].match(/Edfou (\d*)/)[1].strip.to_i if p[0] != nil
                page   = p[1].match(/p. (\d*)/)[1].strip.to_i if p[1] != nil
                plate  = p[2].match(/pl. (.*)\)/)[1].strip if p[2] != nil
              end

            end

            data[i] = {'description' => description,
                       'volume'      => volume,
                       'page'        => page,
                       'plate'       => plate,
                       'polygon'     => area.attr('coords'),
                       'link'        => area.attr('href')}


          end

          # todo: gif not yet implemented (need to be modified like before)
          if (type == 'gif')
            areaString = coordsToString(area)
            data[i]    = array('description' => '',
                               'volume'      => '',
                               'page'        => '',
                               'plate'       => '',
                               'polygon'     => areaString,
                               'areacolor'   => area.attr('color'),
                               'link'        => '',
            )
            unset(area['color'])
          end

          # checks a list with areas that cannot be calculated with the calculation tool
          lists['exceptionList'].each do |exception|
            if (data[i]['link'] == exception || data[i]['polygon'] == exception)
              go = false
            end
          end
          if (go)
            itsAPolygon = false
            areaString  = data[i]['polygon']
            #logger.info "\t[INFO]  [scrape] areaString is #{areaString}"
            areaCoords  = defineCoords(areaString)
            if (!areaCoords)
              areaCoords  = createRectangleFromPolygon(areaString)
              areaCoords  = defineCoords(areaCoords)
              itsAPolygon = true
            end
            areaString  = coordsToString(areaCoords)
            correctWall = checkPosition(room['walls'], areaString)

            # only necessary for polygon areas instead of rectangle
            if (itsAPolygon)
              areaCoords         = fitRectangleToWall(areaString, lists['smallWallsList'], correctWall)
              areaString         = coordsToString(areaCoords)
              correctWall        = checkPosition(room['walls'], areaString)
              data[i]['polygon'] = areaString
              #logger.info "\t[INFO]  [scrape] areaString wird zu #{areaString}"
            end

            # todo: check nil

            data[i].merge!(calculate(areaString, data[i]['link'], correctWall, room['area'], room['mainArea'], lists['angleOfViewList'], room['setting'], true))

          end
          go = true
          i  += 1
        end
      end

    end


    return data

  end


  def calculate(areaString, link, wallAreaString, innerAreaString, mainAreaString, angleOfViewList, setting, transform=false)

    data = Hash.new

    area = defineCoords(areaString)
    if (!area)
      createRectangleFromPolygon(areaString)
      area = defineCoords(areaString)
    end
    if (wallAreaString)
      wall = defineCoords(wallAreaString)
    end
    innerArea = defineCoords(innerAreaString)

    middleX = area['minX'] + (area['maxX'] - area['minX']) / 2.0
    middleY = area['minY'] + (area['maxY'] - area['minY']) / 2.0

    # on top of the innerArea, so set angle to north
    if ((middleY < innerArea['minY'] && setting=='inner') ||
        (middleY > innerArea['maxY'] && setting=='outer'))
      data['angleOfView'] = 0
    end

    # on the right of the inner Area or set manually, so set angle to east
    if ((middleX > innerArea['maxX'] && setting=='inner') ||
        (middleX < innerArea['minX'] && setting=='outer') ||
        angleOfViewList['90degrees'].include?(link) ||
        angleOfViewList['90degrees'].include?(areaString))
      data['angleOfView'] = 90
    end

    # further downwards than the inner Area, so set angle to south
    if ((middleY > innerArea['maxY'] && setting=='inner') ||
        (middleY < innerArea['minY'] && setting=='outer'))
      data['angleOfView'] = 180
    end

    # on the left of the inner Area or set manually, so set angle to west
    if ((middleX < innerArea['minX'] && setting=='inner') ||
        (middleX > innerArea['maxX'] && setting=='outer') ||
        angleOfViewList['270degrees'].include?(link) ||
        angleOfViewList['270degrees'].include?(areaString))
      data['angleOfView'] = 270
    end


    extent = {'x' => ((area['maxX'] - area['minX']) / 2.0),
              'y' => ((area['maxY'] - area['minY']) / 2.0)}

    if (transform)
      extent = transformExtent(mainAreaString, innerAreaString, extent)
    end


    if (data['angleOfView'] == 0)

      data['coord-x'] = middleX

      if (setting == 'inner')
        data['coord-y'] = wall['maxY']
      end


      if (setting == 'outer')
        data['coord-y'] = wall['minY']
      end

      data['height-percent']        = ((wall['maxY'] - middleY).to_f / (wall['maxY'] - wall['minY']) * 100).round(@numbertail)
      data['extent-width']          = extent['x']
      data['extent-height-percent'] = (((area['maxY'] - area['minY']).to_f / (wall['maxY'] - wall['minY'])) * 100 / 2.0).round(@numbertail)
    end

    if (data['angleOfView'] == 180)

      data['coord-x'] = middleX
      if (setting == 'inner')
        data['coord-y'] = wall['minY']
      end
      if (setting == 'outer')
        data['coord-y'] = wall['maxY']
      end
      data['height-percent']        = ((middleY - wall['minY']).to_f / (wall['maxY'] - wall['minY']) * 100).round(@numbertail)
      data['extent-width']          = extent['x']
      data['extent-height-percent'] = (((area['maxY'] - area['minY']).to_f / (wall['maxY'] - wall['minY'])) * 100 / 2.0).round(@numbertail)
    end

    if (data['angleOfView'] == 90)

      if (wallAreaString)

        if (setting == 'inner')
          data['coord-x'] = wall['minX']
        end
        if (setting == 'outer')
          data['coord-x'] = wall['maxX']
        end
        data['coord-y']               = middleY
        data['height-percent']        = ((middleX - wall['minX']).to_f / (wall['maxX'] - wall['minX']) * 100).round(@numbertail)
        data['extent-width']          = extent['y']
        data['extent-height-percent'] = ((area['maxX'] - area['minX']).to_f / (wall['maxX'] - wall['minX']) * 100 / 2.0).round(@numbertail)


        # innerlying areas
      else

        data['coord-x']               = area['minX']
        data['coord-y']               = middleY
        # set innerlying areas to height-percent 50
        data['height-percent']        = 50
        data['extent-width']          = extent['y']
        data['extent-height-percent'] = 50
      end
    end

    if (data['angleOfView'] == 270)

      if (wallAreaString)

        if (setting == 'inner')
          data['coord-x'] = wall['maxX']
        end
        if (setting == 'outer')
          data['coord-x'] = wall['minX']
        end
        data['coord-y']               = middleY
        data['height-percent']        = ((wall['maxX'] - middleX).to_f / (wall['maxX'] - wall['minX']) * 100).round(@numbertail)
        #data['height-percent'] =       ((middleX - wall['maxX']).to_f / (wall['minX'] - wall['maxX']) * 100).round(@numbertail)
        data['extent-width']          = extent['y']
        data['extent-height-percent'] = ((area['maxX'] - area['minX']).to_f / (wall['maxX'] - wall['minX']) * 100 / 2.0).round(@numbertail)

        # innerlying areas
      else

        data['coord-x']               = area['maxX']
        data['coord-y']               = middleY
        # set innerlying areas to height-percent 50
        data['height-percent']        = 50
        data['extent-width']          = extent['y']
        data['extent-height-percent'] = 50
      end
    end

    if (transform)

      newCoord        = transformCoords(mainAreaString, innerAreaString, data['coord-x'], data['coord-y'])
      data['coord-x'] = newCoord['x']
      data['coord-y'] = newCoord['y']
      data['coord-y'] = data['coord-y']
    end

    return data

  end

  def transformCoords(mainAreaString, newAreaString, coordX, coordY)

    mainArea = defineCoords(mainAreaString)
    newArea  = defineCoords(newAreaString)
    scale    = checkScaleRatio(mainArea, newArea)

    newCoordX = (mainArea['minX'] + ((coordX - newArea['minX']) * scale['x'])).round(@numbertail)
    newCoordY = (mainArea['minY'] + ((coordY - newArea['minY']) * scale['y'])).round(@numbertail)
    return {'x' => newCoordX, 'y' => newCoordY}
  end

  def transformExtent(mainAreaString, newAreaString, extent)

    mainArea = defineCoords(mainAreaString)
    newArea  = defineCoords(newAreaString)
    scale    = checkScaleRatio(mainArea, newArea)

    extent['x']= (extent['x'] * scale['x']).round(@numbertail)
    extent['y']= (extent['y'] * scale['y']).round(@numbertail)
    return extent
  end

  def checkScaleRatio(mainArea, newArea)
    scale      = Hash.new
    scale['x'] = (mainArea['maxX'] - mainArea['minX']).to_f /
        (newArea['maxX'] - newArea['minX'])
    scale['y'] = (mainArea['maxY'] - mainArea['minY']).to_f /
        (newArea['maxY'] - newArea['minY'])
    return scale
  end

  def fitRectangleToWall(areaString, smallWalls, wall)

    area = defineCoords(areaString)
    smallWalls.each { |key, value|
      smallWallCoords = defineCoords(value)
      if (wall == key)
        if (area['x1'] < smallWallCoords['minX'])
          area['x1'] = area['minX'] = smallWallCoords['minX']
        end
        if (area['x2']<smallWallCoords['minX'])
          area['x2'] = area['minX'] = smallWallCoords['minX']
        end
        if (area['x1']>smallWallCoords['maxX'])
          area['x1'] = area['maxX'] = smallWallCoords['maxX']
        end
        if (area['x2']>smallWallCoords['maxX'])
          area['x2'] = area['maxX'] = smallWallCoords['maxX']
        end
        if (area['y1']<smallWallCoords['minY'])
          area['y1'] = area['minY'] = smallWallCoords['minY']
        end
        if (area['y2']<smallWallCoords['minY'])
          area['y2'] = area['minY'] = smallWallCoords['minY']
        end

        if (area['y1']>smallWallCoords['maxY'])
          area['y1'] = area['maxY'] = smallWallCoords['maxY']
        end

        if (area['y2']>smallWallCoords['maxY'])
          area['y2'] = area['maxY'] = smallWallCoords['maxY']
        end
        return area
      end
    }
  end

  def defineCoords(coords)

    if coords.class == String
      coordString = coords.gsub(' ', '')
      coords      = coordString.split(',')
    end

    if (coords.size > 4)
      return false
    end

    coords_hash = Hash.new

    coords_hash['x1'] = coords[0].to_i
    coords_hash['y1'] = coords[1].to_i
    coords_hash['x2'] = coords[2].to_i
    coords_hash['y2'] = coords[3].to_i

    coords_hash['minX'] = coords_hash['x1'] < coords_hash['x2'] ? coords_hash['x1'].to_i : coords_hash['x2'].to_i

    coords_hash['maxX'] = coords_hash['x1'] > coords_hash['x2'] ? coords_hash['x1'].to_i : coords_hash['x2'].to_i
    coords_hash['minY'] = coords_hash['y1'] < coords_hash['y2'] ? coords_hash['y1'].to_i : coords_hash['y2'].to_i
    coords_hash['maxY'] = coords_hash['y1'] > coords_hash['y2'] ? coords_hash['y1'].to_i : coords_hash['y2'].to_i

    return coords_hash

  end

  def checkPosition(wallAreas, areaString)

    area = defineCoords(areaString)

    wallAreas.each { |wall|
      wallCoords = defineCoords(wall)
      if ((area['maxX']-3 <= wallCoords['maxX']) &&
          (area['minX']+3 >= wallCoords['minX']) &&
          (area['maxY']-3 <= wallCoords['maxY']) &&
          (area['minY']+3 >= wallCoords['minY']))

        return wall
      end

    }

    return false

  end

  def coordsToString(coords)
    str = "#{coords['minX']},#{coords['minY']},#{coords['maxX']},#{coords['maxY']}"
    return str
  end

  def createRectangleFromPolygon(polygonString)

    polygonString = polygonString.gsub(' ', '')
    polygon       = polygonString.split(',')
    i             = 0
    x             = Array.new
    y             = Array.new

    while i < polygon.size
      # check if polygon coord is on first, third, etc position
      #keys = array_keys(polygon)
      if (i % 2 == 0)
        x << polygon[i]

        # otherwise its on second etc position, so it is the y coordinate
      else
        y << polygon[i]
      end
      i += 1
    end

    # sort and delete all but the smallest and biggest coordinate
    xsort        = x.sort
    x            = [xsort.first, xsort.last]
    ysort        = y.sort
    y            = [ysort.first, ysort.last]

    # build a string with the rectangle coordinates
    coordsString = "#{x[0]},#{y[0]},#{x[1]},#{y[1]}"
    return coordsString

  end


  def checkForAreas(site)

    if (areas = sitesite.xpath('//area'))
      return areas
    else
      return false
    end
  end

# Checks for image maps
#
# :call-seq:
#
#   site -> URL of site
# return the found imagemaps
  def checkForImageMaps(site)

    # Find all imagemaps on actual html site
    if maps = site.xpath('//map')
      return maps
    else
      return false
    end

  end

  def checkForAreas(site)

    if (areas = site.xpath('//area'))
      return areas
    else
      return false
    end
  end

# Searches for rectangles in gif files with specific indexed colors
#
# :call-seq:
#
# fileName -> gif file
# colors   -> array with colors to search for
# border   -> amount of pixels wich are added to the found rectangles
# cut      -> array with coordinates where the search starts or ends (x1,y1,x2,y2)
#
# # return the areas with the specific color(s)
  def findAreasFromImage(fileName, colors = Array.new(2), border = 0, cut = false)

    im     = MiniMagick::Image.open(fileName)
    width  = im.width # image width
    height = im.height # image height

    # set starting coordinate default
    startx = 0
    starty = 0

    if cut
      if cut.has_key?('x1')
        startx = cut['x1']
      end
      if cut.has_key?('y1')
        starty = cut['y1']
      end
      if cut.has_key?('x2')
        width = cut['x2']
      end
      if cut.has_key?('y2')
        height = cut['y2']
      end
    end

    i           = 0
    firstLoop   = true
    wasDetected = false

    # process the image line for line
    colors.each do |color|

      y = starty
      x = startx

      until  y < height do
        until x < width
          # check if pixel has the correct color
          if (imagecolorat(im, x, y) == color)
            # stdOut("Color color found at x:x, y:y");
            if !firstLoop
              # check if area is already detected
              areas.each do |area|
                if ((x>=area['x1']) &&
                    (x<=area['x2']) &&
                    (y>=area['y1']) &&
                    (y<=area['y2']) &&
                    (color==area['color']))
                  wasDetected = true;
                  break;
                else
                  wasDetected = false;

                end
              end
            end
            tempX = x
            tempY = y
            # define first coordinate
            if (!wasDetected)
              # stdOut("Creating new area with starting coordinates tempX and tempY with index i");
              areas[i]['x1'] = tempX - border
              areas[i]['y1'] = tempY - border
            end
            # find last correct color of area
            while (imagecolorat(im, tempX, tempY)==color)
              tempX += 1
            end
            tempX -= 1
            if (!wasDetected)
              # stdOut("Last x coordinate for area with index i is at tempX")
              areas[i]['x2'] = tempX + border

            end

            while (imagecolorat(im, tempX, tempY)==color)
              tempY += 1
            end
            if (!wasDetected)
              areas[i]['y2']    = tempY + border
              areas[i]['color'] = color
              # stdOut("Last y coordinate for area with index i is at tempY")
            end

            x         = tempX+1
            firstLoop = false
            if (!wasDetected)
              i += 1
            end

          end

          x += 1

        end
        y += 1
      end
    end
    imagedestroy(im)
    return areas
  end

end


# remove this
Scrape.new

