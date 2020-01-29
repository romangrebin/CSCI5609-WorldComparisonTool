/**
  File is set up with the functions that create graphs in the beginning, with function names starting with create____()
  Following the "create" functions are the "draw" functions, to place a graph in a window. These are in the same order as the create() functions
*/

static class Graphs {
  
  //static String PADDING = "                        -                        ";
  static String[] sortedBarCountryNames;
  Graphs() {
    println("I don't think this can ever get printed.");
  }
  
  /**
    The function returns a BarChart bar graph which can be drawn with drawBarChart() (next function in this file)
    Takes one indicator, with the name of the indicator AS A SINGLE STRING in the variable 'indicator'
  */
  static BarChart createBarChart(PApplet parent, CountryDatabase world, String indicator, int year, String[] countryNames) {
    
    BarChart barchart = new BarChart(parent);
    
    //int numCountries = world.countryShapes.getChildCount();
    int numCountries = countryNames.length;
    float[] values = new float[numCountries];
    //String[] countryNames = new String[numCountries];
    
    // Get the value and name of each country
    for (int i = 0; i < numCountries; i++) {
      //countryNames[i] = world.countries.get(i).getName();
      //values[i] = world.countries.get(i).getData().getIndicatorValue(indicator, year);
      values[i] = world.getCountry(countryNames[i]).getData().getIndicatorValue(indicator,year);
    }
    
    // SORT VALUES AND COUNTRYNAMES
    /// TODO: (Probably want to break this out into separate function - also, bubblesort sucks)
    boolean unsorted = true;
    float tempNum;
    String tempCountry;
    while(unsorted) {
      unsorted = false;
      for (int i = 0; i < numCountries - 1; i++) {
        if (values[i] < values[i+1]) {
          tempNum = values[i];
          tempCountry = countryNames[i];
          
          values[i] = values[i+1];
          countryNames[i] = countryNames[i+1];
          
          values[i+1] = tempNum;
          countryNames[i+1] = tempCountry;
          unsorted = true;
        }
        
      }
      
    }
    sortedBarCountryNames = new String[numCountries];
    System.arraycopy(countryNames, 0, sortedBarCountryNames, 0, countryNames.length);
    barchart.setData(values);
    barchart.setBarLabels(countryNames);
    barchart.setCategoryAxisLabel("Countries");
    barchart.setValueAxisLabel(indicator);
    
    barchart.setBarColour(0);
    // Set the minimum value for the value axis
    barchart.setMinValue(0);
    // Show the values axis
    barchart.showValueAxis(true);
    // Show category axis
    barchart.showCategoryAxis(true);
    // Flip the axes so categories are on left
    barchart.transposeAxes(true);
    
    return barchart;
  }
  
  
  /**
    Creates and returns a gicentre scatterplot (un-drawn) with xIndicator values on the left axis and yIndicator values on the right axis
  */
  static XYChart createScatterPlot(PApplet parent, CountryDatabase world, String xIndicator, String yIndicator, int year, String[] countryNames) {
    
    XYChart plot = new XYChart(parent);
    
    //int numCountries = world.countryShapes.getChildCount();
    int numCountries = countryNames.length;
    
    float[] valuesY = new float[numCountries];
    float[] valuesX = new float[numCountries];
    //String[] countryNames = new String[numCountries];
    
    // Get the value and name of each country
    for (int i = 0; i < numCountries; i++) {
      //countryNames[i] = world.countries.get(i).getName();
      //valuesY[i] = world.countries.get(i).getData().getIndicatorValue(yIndicator, year);
      //valuesX[i] = world.countries.get(i).getData().getIndicatorValue(xIndicator, year);
      valuesX[i] = world.getCountry(countryNames[i]).getData().getIndicatorValue(xIndicator,year);
      valuesY[i] = world.getCountry(countryNames[i]).getData().getIndicatorValue(yIndicator,year);
    }
    
    plot.setData(valuesX, valuesY);
    
    plot.showXAxis(true);
    plot.showYAxis(true);
    
    plot.setMinX(0);
    plot.setMinY(0);
    
    plot.setXAxisLabel(xIndicator);
    plot.setYAxisLabel(yIndicator);
    
    return plot;
  }
  
  /**
   Creates and returns a scatterplot made using the grafica library - it can be draw with the drawGraficaScatter() function
   */
  static GPlot createGraficaScatter(PApplet parent, CountryDatabase world, String xIndicator, String yIndicator, int year, String[] countryNames) {
    GPlot plot = new GPlot(parent);
    //int numCountries = world.countryShapes.getChildCount();
    int numCountries = countryNames.length;
    GPointsArray points = new GPointsArray(numCountries);
    
    float xValue;
    float yValue;
    // Populate the GPointsArray with GPoints
    for (int i = 0; i < numCountries; i++) {
      //countryName = world.countries.get(i).getName();
      xValue = world.getCountry(countryNames[i]).getData().getIndicatorValue(xIndicator,year);
      yValue = world.getCountry(countryNames[i]).getData().getIndicatorValue(yIndicator,year);
      //xValue = world.countries.get(i).getData().getIndicatorValue(xIndicator, year);
      //yValue = world.countries.get(i).getData().getIndicatorValue(yIndicator, year);
      points.add(xValue, yValue, countryNames[i] + " " + String.valueOf(xValue) + ", " + String.valueOf(yValue)  );
    }
    plot.setPoints(points);
    plot.setTitleText(xIndicator + " vs " + yIndicator);
    plot.getXAxis().setAxisLabelText(xIndicator);
    plot.getYAxis().setAxisLabelText(yIndicator);
    
    return plot;
  }
  
  
  /**
    Create a Line Plot using Grafica. The x-axis is time, with a point for each year.
    The y-axis is the value for an indicator
    Each separate line is a different country
  */
  static GPlot createGraficaLine(WorldComparisonTool worldTool, PApplet parent, CountryDatabase world, String indicator, String[] countryNames) {
    GPlot plot = new GPlot(parent);
    
    int numCountries = countryNames.length;
    //int numYears = world.getCountry(countryNames[0]).getData().getIndicatorValues(indicator).size();
    int numYears = Config.END_YEAR - Config.START_YEAR + 1;
    GLayer layer;
    // one GPointsArray for each country. Each GPointsArray has a point for each year
    GPointsArray[] countryPointsLists = new GPointsArray[numCountries];
    float yValue;
    // for each country
    for (int countryIndex = 0; countryIndex < numCountries; countryIndex++) {
      // add a point for this country for each of the years
      countryPointsLists[countryIndex] = new GPointsArray(numYears);
      for (int year = 0; year < numYears; year++) {
        yValue = world.getCountry(countryNames[countryIndex]).getData().getIndicatorValue(indicator,year+Config.START_YEAR);
        if (yValue > 0) {
          countryPointsLists[countryIndex].add(year+Config.START_YEAR, yValue, countryNames[countryIndex] + " " + String.valueOf(yValue));
        }
      }
      
      plot.addLayer(countryNames[countryIndex],countryPointsLists[countryIndex]);
      layer = plot.getLayer(countryNames[countryIndex]);
      layer.setLineWidth(4);
            
      layer.setLineColor(worldTool.randomColor());
    }
    plot.getXAxis().setNTicks(numYears);
    plot.setTitleText("Country " + indicator + " values over time");
    plot.getXAxis().setAxisLabelText("Year");
    plot.getYAxis().setAxisLabelText(indicator);
    
    return plot;
  }
  
  static GPlot[] createScatterMatrix(PApplet parent, CountryDatabase world, String[] indicators, int year, String[] countryNames) {
    
    GPlot[] scatterplots = new GPlot[(int)Math.pow(indicators.length, 2)];
    
    int numCountries = countryNames.length;
    // each row in the matrix
    for (int i = 0; i < indicators.length; i++) {
      //print("Doing row ");
      //println(i);
      // each column in the matrix
      for (int j = 0; j < indicators.length; j++) {
        GPointsArray points = new GPointsArray(numCountries);
        for (int pointNum = 0; pointNum < numCountries; pointNum++) {
          float xValue = world.getCountry(countryNames[pointNum]).getData().getIndicatorValue(indicators[j],year);
          float yValue = world.getCountry(countryNames[pointNum]).getData().getIndicatorValue(indicators[i],year);
          points.add(xValue, yValue, countryNames[pointNum] + " " + indicators[j] + ", " + indicators[i]);
        }
        //print("adding plot to scatterplots, number: ");
        //println(indicators.length*i + j + 1);
        scatterplots[(indicators.length * i + j)] = new GPlot(parent);
        //println("added plot to scatterplots");
        scatterplots[(indicators.length * i + j)].setPoints(points);
        scatterplots[(indicators.length * i + j)].setPointSize(3);
      }
    }
    
    
    return scatterplots;
  }
  
  static PTreeMappa createTreeMap(PApplet parent, CountryDatabase world, String indicator, String[] countryNames, int year){
    PTreeMappa treemap = new PTreeMappa(parent);
    TreeMapNode root = new TreeMapNode("countries");
    treemap.getTreeMappa().setRoot(root);
    for (int i=0; i < countryNames.length; i++) {
      String n = countryNames[i];
      root.add(new TreeMapNode(n, world.getCountry(n).getData().getIndicatorValue(indicator, year)));
    }
  treemap.buildTreeMap();
  
      
  TreeMapPanel tmPanel = treemap.getTreeMapPanel();

  tmPanel.setShowBranchLabels(true);
  tmPanel.setLeafTextAlignment(RIGHT,BOTTOM);
  tmPanel.setBranchMaxTextSize(0,80);
  tmPanel.setBranchMaxTextSize(1,30);
  tmPanel.setLeafMaxTextSize(20);
  tmPanel.setAllowVerticalLabels(true);
  
  tmPanel.updateLayout();
  treemap.buildTreeMap();
  //for (int i=0; i < root.getChildCount(); i++) {
  //    java.awt.geom.Rectangle2D loc = root.getChildAt(i).calcGeoBounds();
  //    println(root.getChildAt(i).getLabel() + ": (" + (((int)loc.getX()) + 15) + ", " + (((int)loc.getY()) + 35) +"), value: " + root.getChildAt(i).getSizeValue());
  //    println("width/height: " + loc.getWidth() + "/" + loc.getHeight());
  //    //root.getChildAt(i).setLabel(((int)loc.getX() + 15) + ", " + ((int)loc.getY() + 35));
  //}
  return treemap;
  }
  
  static void drawTreeMap(PApplet parent, PTreeMappa treemap, int xpos, int ypos, int xdim, int ydim) {
    if (xpos == -1) {
      treemap.draw();
    }
    else {
      treemap.draw(xpos, ypos, xdim, ydim);  
    }
    if (!rectContains(parent.mouseX, parent.mouseY, xpos, ypos, xdim, ydim)) {
      return;
    }
    //parent.text(parent.mouseX + "," + parent.mouseY, parent.mouseX, parent.mouseY);
    float ratioW = xdim / ((float) Config.GWIDTH), ratioH = ydim / ((float) Config.GHEIGHT);
    TreeMapNode activeNode = null, root = treemap.getTreeMappa().getRoot();
    for (int i=0; i < root.getChildCount(); i++) {
      activeNode = root.getChildAt(i);
      java.awt.geom.Rectangle2D rect = activeNode.calcGeoBounds();
      if (rectContains(parent.mouseX, parent.mouseY, (float)(xpos + rect.getX()*ratioW), (float)(ypos + rect.getY()*ratioH), (float)rect.getWidth() * ratioW, (float)rect.getHeight() * ratioH)) {
        //println("country that contains: " + activeNode.getLabel());
        //println("coords: " + rect.getX() + ", " + rect.getY());
        break;  
      }
    }
    parent.text(activeNode.getLabel() + ": " + ((long)activeNode.getSizeValue()), parent.mouseX, parent.mouseY);
  }
  // draw a barchart created using the gicentre utils library
  static void drawBarChart(PApplet parent, BarChart chart, int xpos, int ypos, int xdim, int ydim) {
    // Make background for the chart
    parent.stroke(255);
    parent.fill(255);
    parent.rect(xpos, ypos, xdim, ydim);
    
    // reset textSize to 10 for the tick labels
    parent.textSize(10);
    
    
    chart.draw(xpos, ypos, xdim, ydim);
    
    PVector mousePos = new PVector(parent.mouseX, parent.mouseY);
    PVector currentData = new PVector(0,0);
    // getScreenToData returns a PVector with x = country index (reverse order??)
    //    y = current value directly corresponding to mouse location
    currentData = chart.getScreenToData(mousePos);
    // Add a label to the current mouse location
    if (currentData != null) {    
      // Set the font data
      parent.textSize(15);
      parent.fill(150);
      parent.textAlign(LEFT);
      /// TODO: Maybe add a box behind the text so it is legible anywhere?
      
      float[] values = chart.getData();
      // For some reason we need 193 - because indices are reversed??? Works like this.
      float floatVal = values[values.length - (int)currentData.x - 1];
      // Change the label so it is: "[CountryName]: [Value]"
      //   Haven't found a way to access the list of country names from the chart object.
      //   In the AbstractChart class (which BarChart extends), there is a field float[][]
      //    which holds the country indices and their corresponding values. getData(1) or getData(0) should work:
      //    http://gicentre.org/utils/reference/org/gicentre/utils/stat/AbstractChart.html#getData-int-
      String countryName = sortedBarCountryNames[values.length - (int)currentData.x - 1];
      parent.text(countryName + ": " + floatVal, parent.mouseX + 15, parent.mouseY);
    }
  }
  
  // Draws ScatterPlot returned from createScatterPlot function (gicentre!)
  static void drawScatterPlot(PApplet parent, XYChart plot, int xpos, int ypos, int xdim, int ydim) {
    // Make background for the chart
    parent.stroke(255);
    parent.fill(255);
    parent.rect(xpos, ypos, xdim, ydim);
    
    parent.textSize(14);
    
    plot.draw(xpos, ypos, xdim, ydim);
  }
  
  // Draws grafica ScatterPlot returned from createGraficaScatter function (GRAFICA!)
  static void drawGraficaScatter(PApplet parent, GPlot plot, int xpos, int ypos, int xdim, int ydim) {
    plot.setPos(xpos, ypos);
    plot.setDim(xdim, ydim);
    //plot.activatePointLabels(CENTER);
    
    plot.beginDraw();
    plot.drawBackground();
    plot.drawPoints();
    plot.drawYAxis();
    plot.drawXAxis();
    plot.drawLabelsAt(parent.mouseX, parent.mouseY);
    plot.drawTitle();
    //plot.drawLabels();
    plot.endDraw();
  }
  
  static void drawGraficaLine(PApplet parent, GPlot plot, int xpos, int ypos, int xdim, int ydim) {
    plot.setPos(xpos, ypos);
    plot.setDim(xdim, ydim);
    parent.strokeWeight(4);
    
    plot.beginDraw();
    plot.drawBox();

    plot.drawXAxis();
    plot.drawYAxis();
    plot.drawTitle();
    plot.drawGridLines(GPlot.VERTICAL);
    //plot.drawFilledContours(GPlot.HORIZONTAL, 0);
    plot.drawLabels();
    //plot.drawPoints();
    plot.drawLines();
    plot.drawLabelsAt(parent.mouseX, parent.mouseY);
    plot.endDraw(); 
  }
  
  static void drawScatterMatrix(PApplet parent, GPlot[] plots, String[] indicatorNames, int xmin, int ymin, int xdim, int ydim) {
    parent.textSize(8);
    parent.textAlign(LEFT,TOP);
    // For each row in the scatterplot matrix
    for (int i = 0; i < indicatorNames.length; i++) {
      // Add row indicator name
      //println(indicatorNames[i]);
      parent.text(Integer.toString(i + 1) + ".", xmin + 25, ymin + (i + 1)*(ydim / indicatorNames.length));
      // Add column indicator name
      parent.text(Integer.toString(i + 1) + ". " + indicatorNames[i], xmin + (i+.5)*(xdim / indicatorNames.length), ymin + 15);
      // For each column in the scatterplot matrix
      for (int j = 0; j < indicatorNames.length; j++) {
        plots[(indicatorNames.length * i + j)].setPos(xmin + (j * (xdim / indicatorNames.length)), ymin + (i * (ydim / indicatorNames.length)));
        plots[(indicatorNames.length * i + j)].setDim(xdim / indicatorNames.length, ydim / indicatorNames.length);
        plots[(indicatorNames.length * i + j)].beginDraw();
        plots[(indicatorNames.length * i + j)].drawBox();
        plots[(indicatorNames.length * i + j)].drawPoints();
        plots[(indicatorNames.length * i + j)].drawLabelsAt(parent.mouseX, parent.mouseY);
        plots[(indicatorNames.length * i + j)].endDraw();
      }
      
    }
    
  }
  
  

  static boolean rectContains(float x, float y, float rX, float rY, float rWidth, float rHeight) {
    return (x > rX && x < rX + rWidth && y > rY && y < rY + rHeight); 
  }
}