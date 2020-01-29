import controlP5.*;
import g4p_controls.*;
import grafica.*;
import org.gicentre.utils.stat.*;
import org.gicentre.utils.move.*;
import org.gicentre.treemappa.*;      // For treemappa classes
import org.gicentre.utils.colour.*;   // Colours needed by treemappa.
//import java.awt.event.KeyEvent; 

//GButton testing;

// variables to assist with drag-select functionality
int dragAreaX = 0, dragAreaY = 0, dragWidth = 0, dragHeight = 0;
boolean shouldDrawDragArea = false;
color dragAreaFill = color(50,0,255,100);

// graph creator page GUI elements
GButton createGraphButton;
GWindow win;

GButton activeCategoryButton, countryCategoryButton, indicatorCategoryButton;
ArrayList<GButton> countryButtons = new ArrayList<GButton>();
ArrayList<GButton> indicatorButtons = new ArrayList<GButton>();
GDropList graphTypes, graphYearsList;

// redirect button variables
boolean onMapPage = true, showTitle = true, showCredits = true, playingMapYears = false;
GButton graphRedirect, mapRedirect;

// map (intro) page GUI elements
GTextArea indicatorText, yearText;
GButton applyButton, playMapYearsButton;
GDropList indicatorList, yearList;
GCheckbox logCheck;

// graph viewer GUI elements
GButton chartNextYearButton, chartPrevYearButton;

String selectedIndicator;
// currentChartYear is the actual year date (as opposed to array indices)
int currentChartYear;
// Keeps track of how many frames have passed since the last auto-advance occurred.
int framesSinceAdvancing;

// zoom / pan object
ZoomPan z;

// da database of the world
CountryDatabase world;

//_______________________________
BarChart chart;
XYChart plot;
GPlot graficaPlot;
GPlot graficaLine;
GPlot[] scatterMatrix;
PTreeMappa treemap;
String activeChart;
//_______________________________

void settings() {
  this.size(1280, 700);  
}
void setup() {
  world = new CountryDatabase("out.geojson.txt");
  
  // initialize graph display window
  win =  GWindow.getWindow(this, "test window", 100, 50, Config.GWIDTH, Config.GHEIGHT, JAVA2D);
  win.addDrawHandler(this, "GWindowDraw");
  win.addKeyHandler(this, "GKeyHandler");
  win.setVisible(false);
  initGraphGUI();
  
  ////////////////////////////////////////
  // set up graph window GUI elements
  //testing = new GButton(win, 750, 20, 80, 25, "testing");
  chartNextYearButton = new GButton(win, 620, 10, 100, 25, "Next Year");
  chartPrevYearButton = new GButton(win, 450, 10, 100, 25, "Previous Year");
  
  chartNextYearButton.addEventHandler(this, "chartNextYearHandler");
  chartPrevYearButton.addEventHandler(this, "chartPrevYearHandler"); //Integer.toString(currentChartYear)
  
  ///////////////////////////////////////
  // set up redirect buttons to switch between intro page and graph creator 
  graphRedirect = new GButton(this, 1200, 10, 60, 40, "graph creator");
  mapRedirect = new GButton(this, 1200, 10, 60, 40);
  
  mapRedirect.setText("general map");
   
  graphRedirect.addEventHandler(this, "redirectButtonHandler");
  mapRedirect.addEventHandler(this, "redirectButtonHandler");
   
  mapRedirect.setVisible(false);
  
  //////////////////////////////////////
  // set up map (intro) GUI elements
  indicatorList = new GDropList(this, 140, 40, 300, 100, 5);
  yearList = new GDropList(this, 565, 40, 100, 100, 5);
  logCheck = new GCheckbox(this, 830, 25, 130, 50, "log scaling");
  applyButton = new GButton(this, 950, 40, 80, 20, "apply");
  applyButton.addEventHandler(this, "applyButtonHandler");
  
  playMapYearsButton = new GButton(this, 672, 39, 100, 20, "Auto-Advance");
  playMapYearsButton.addEventHandler(this, "playMapHandler");

  //////////////////////////////////////
  // set up zoom capabilities
  z = new ZoomPan(win);
  z.setMouseMask(SHIFT);
  //////////////////////////////////////
  // create empty world database from data file

  
  //////////////////////////////////////
  // various world testing (output to console)
  println(world.countryShapes.getChildCount());
  test(world);
  
  //////////////////////////////////////
  // create indicator list to be output to console
  String[] indicators = world.getIndicators();
  for (int i=0; i < indicators.length; i++) {
    println("indicator " + i + ": " + indicators[i]); 
  }
  
  //////////////////////////////////////
  // set year list, indicators, and event handlers
  yearList.setItems(Config.getYears(), 0);
  yearList.addEventHandler(this, "mapListModified");
  indicatorList.setItems(indicators, 0);
  indicatorList.addEventHandler(this, "mapListModified");
  
  
  currentChartYear = Config.START_YEAR;
  selectedIndicator = indicatorList.getSelectedText();
  
  framesSinceAdvancing = 0;
  
  world.applyIndicator(selectedIndicator, 1997, logCheck.isSelected());
}


  
color randomColor() {
  color c = color(random(255), random(255), random(255));
  return c;
}


// Main draw function ------------------------------------------ Main draw function
void draw() {  
  this.background(240,240,240);
  //z.transform();
  
  if (onMapPage) {
    world.draw();
    drawMapPageText();
    drawMapLegend();
    if (playingMapYears) {
      // Change the pace of auto-advancing by changing the mod number
      framesSinceAdvancing = (framesSinceAdvancing + 1) % 5;
      if (framesSinceAdvancing == 0) {
        // change the year drop-down list
        int nextSelected = yearList.getSelectedIndex() + 1;
        if (nextSelected == Config.getYears().length) {
          nextSelected = 0;
        }
        yearList.setSelected(nextSelected);
        // applyIndicator()
        world.applyIndicator(indicatorList.getSelectedText(), Integer.parseInt(yearList.getSelectedText()), logCheck.isSelected());
      }
    }
  }
  else {
    drawGraphCreatorPageText();
    if (shouldDrawDragArea) {
      drawDragArea();  
    }
  }

  drawMainGUI();
  
  //_________________________________
  //Graphs.drawBarChart(this, chart, 15, 35, 600, 2500);
  //Graphs.drawGraficaScatter(this, graficaPlot, 15, 35, 600, 600);
  //Graphs.drawScatterPlot(this, plot, 625, 35, 600, 600);
  //_________________________________
}

// currently unused
void mapListModified(GDropList list, GEvent event) {
  
  //___________________________ Remake the chart with the new indicator
  //chart = Graphs.createBarChart(this, world, selectedIndicator, 2005);
  //plot = Graphs.createScatterPlot(this, world, selectedIndicator, "Population total", 2005);
  //graficaPlot = Graphs.createGraficaScatter( this, world, selectedIndicator, "Population total", 2005);
  //___________________________

}



void categoryButtonClicked(GButton button, GEvent event) {
  if (button == activeCategoryButton) {
    return;  
  }
  updateGraphGUIVisibility(true);
}



// this is the function where you will change the various graph / chart / plot objects you've created. 
void createGraphButtonClicked(GButton button, GEvent event) {
  win.setVisible(true);  ///_________________________
  currentChartYear = getSelectedYear(); 
  recreateGraphs();
}

// remake graphs based on new information
void recreateGraphs() {  
  String[] indicator = getSelectedIndicators();
  String[] countryList = getSelectedCountries();
  chart = Graphs.createBarChart(win, world, indicator[0], currentChartYear, countryList);
  graficaLine = Graphs.createGraficaLine(this, win, world, indicator[0], countryList);
  if (indicator.length < 2) {
    plot = Graphs.createScatterPlot(win, world, indicator[0], "Population total", currentChartYear, countryList);
    graficaPlot = Graphs.createGraficaScatter( win, world, indicator[0], "Population total", currentChartYear, countryList);
    treemap = Graphs.createTreeMap(win, world, indicator[0], countryList, currentChartYear);
  }
  else {
    plot = Graphs.createScatterPlot(win, world, indicator[0], indicator[1], currentChartYear, countryList);
    graficaPlot = Graphs.createGraficaScatter( win, world, indicator[0], indicator[1], currentChartYear, countryList);
  }
  scatterMatrix = Graphs.createScatterMatrix(win, world, indicator, currentChartYear, countryList);
  // __________________________
  
}

void countrySelected(GButton button, GEvent event) {
  if (button.getLocalColorScheme() == GCScheme.BLUE_SCHEME) {
    button.setLocalColorScheme(GCScheme.GREEN_SCHEME); 
  }
  else {
    button.setLocalColorScheme(GCScheme.BLUE_SCHEME);   
  }
}

void chartNextYearHandler(GButton button, GEvent event) {
  if (currentChartYear == Config.END_YEAR) {
    currentChartYear = Config.START_YEAR;
  }
  else {
    currentChartYear++;
  }
  recreateGraphs();
}

void chartPrevYearHandler(GButton button, GEvent event) {
  if (currentChartYear == Config.START_YEAR) {
    currentChartYear = Config.END_YEAR;
  }
  else {
    currentChartYear--;
  }
  recreateGraphs();
}

void applyButtonHandler(GButton button, GEvent event) {
  world.applyIndicator(indicatorList.getSelectedText(), Integer.parseInt(yearList.getSelectedText()), logCheck.isSelected());
}

void playMapHandler(GButton button, GEvent event) {
  if (playingMapYears) {
    button.setText("Auto-Advance");
  }
  else {
    button.setText("Pause");
  }
  playingMapYears = !playingMapYears;
}


void redirectButtonHandler(GButton button, GEvent event) {
     println("in button handler");
     if (mapRedirect != null && graphRedirect != null) {
       onMapPage = !onMapPage;
       
       // toggle visibility of redirect buttons
       mapRedirect.setVisible(!onMapPage);
       graphRedirect.setVisible(onMapPage);
       mapRedirect.setLocalColorScheme(!onMapPage ? GCScheme.GREEN_SCHEME : GCScheme.BLUE_SCHEME);
       graphRedirect.setLocalColorScheme(!onMapPage ? GCScheme.GREEN_SCHEME : GCScheme.BLUE_SCHEME);
       
       // toggle visibility of map (intro) page GUI 
       indicatorList.setVisible(onMapPage);
       yearList.setVisible(onMapPage);
       logCheck.setVisible(onMapPage);
       applyButton.setVisible(onMapPage);
       playMapYearsButton.setVisible(onMapPage);
       
       updateGraphGUIVisibility(false);
       countryCategoryButton.setVisible(!onMapPage);
       indicatorCategoryButton.setVisible(!onMapPage);
       graphTypes.setVisible(!onMapPage);
       graphYearsList.setVisible(!onMapPage);
       createGraphButton.setVisible(!onMapPage);
     }
}

void drawMainGUI() {
   if (showTitle) {
     // Draw Title in top middle of page
     this.textAlign(CENTER);
     this.fill(0);
     this.textSize(30);
     this.text("World Comparison Tool", 640, 25);
   }
  
   if (showCredits) {
     // Credits at bottom right of page
     this.textSize(12);
     this.textAlign(RIGHT);
     this.text("Developed for UMN CSCI 5609", width-5, height-50);
     this.text("Spring 2017", width-5, height-35);
     this.text("Mina Yacoup", width-5, height-20);
     this.text("Roman Grebin", width-5, height-5);
   }

 }
 
void drawMapPageText() {
    this.textSize(12);
    this.text("Indicators: ", 135, 52);
    this.text("Years: ", 560, 52);
}

void drawMapLegend() {
  textAlign(LEFT);
  
  // No data, black rectangle
  fill(0);
  rect(80, 450, 20, 20);
  text("No data", 105, 465);
  
  color c1 = Config.gradientEnd;
  color c2 = Config.gradientStart;
  
  for (int y = 500; y <= 650; y++) {
    float mappedVal = map(y, 500, 650, 0, 1);
    color c = lerpColor(c1, c2, mappedVal);
    stroke(c);
    line(50, y, 100, y);
  }
  noFill();
  stroke(0);
  rect(50, 500, 50, 150);
  

  // Add the max and min labels to the legend
  text(Float.toString(world.maxValue), 105, 505);
  text(Float.toString(world.minValue), 105, 655);
  float val34, val12, val14;
  if (world.logScale) {
    // Calculate 3/4 total
    float temp = (float)((.75* (Math.log10(world.maxValue) - Math.log10(world.minValue))) + Math.log10(world.minValue));
    val34 =  pow(10, temp);
    
    temp = (float)((.5* (Math.log10(world.maxValue) - Math.log10(world.minValue))) + Math.log10(world.minValue));
    val12 = pow(10, temp);
    
    temp = (float)((.25* (Math.log10(world.maxValue) - Math.log10(world.minValue))) + Math.log10(world.minValue));
    val14 = pow(10, temp);
  }
  else {
    val34 = map(.75, 0, 1, world.minValue, world.maxValue);
    val12 = map(.5, 0, 1, world.minValue, world.maxValue);
    val14 = map(.25, 0, 1, world.minValue, world.maxValue);
  }
  
  text(Float.toString(val34), 105, 542);
  text(Float.toString(val12), 105, 580);
  text(Float.toString(val14), 105, 617);
  
}

void drawGraphCreatorPageText() {
    this.textSize(16);
    this.text("Graph Creator", 320, 37);
    this.textSize(12);
    this.text("Graph Type: ", 990, 93);
    this.text("Year: ", 990, 213);
}

void initGraphGUI() {
  if (world == null) {
    return; 
  }
  
  graphTypes = new GDropList(this, 1000, 80, 140, 200, 10);
  graphTypes.setVisible(false);
  graphTypes.setItems(Config.chartTypes, 0);
  
  graphTypes.addEventHandler(this, "graphTypesListModified");
  
  graphYearsList = new GDropList(this, 1000, 200, 140, 200, 10);
  graphYearsList.setVisible(false);
  String[] yearsList = new String[Config.END_YEAR - Config.START_YEAR + 1];
  for (int i = 0; i <= Config.END_YEAR - Config.START_YEAR; i++) {
    yearsList[i] = Integer.toString(Config.START_YEAR + i);
  }
  graphYearsList.setItems(yearsList, 0);
  
  
  createGraphButton = new GButton(this, 1100, 600, 100, 25, "create graph");
  createGraphButton.addEventHandler(this, "createGraphButtonClicked");
  createGraphButton.setVisible(false);

  countryCategoryButton = new GButton(this, 10, 20, 80, 25, "Countries");
  indicatorCategoryButton = new GButton(this, 100, 20, 80, 25, "Indicators");
  
  countryCategoryButton.addEventHandler(this, "categoryButtonClicked");
  indicatorCategoryButton.addEventHandler(this, "categoryButtonClicked");
  
  countryCategoryButton.setVisible(false);
  indicatorCategoryButton.setVisible(false);
  
  activeCategoryButton = countryCategoryButton;
  activeCategoryButton.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  
  // create country multi-select interface
  int yOffset = 50, xOffset = 21, buttonWidth = 120, buttonHeight = 22, numRows = 28;
  
  for (int i=0; i < world.countries.size(); i++) {
    String name = world.countries.get(i).getName();
    GButton current = new GButton(this, xOffset + (i/numRows) * buttonWidth, yOffset + (buttonHeight * (i % numRows)), buttonWidth, buttonHeight, name);
    countryButtons.add(current);
    current.addEventHandler(this, "countrySelected");
    current.setVisible(false);
    current.setAlpha(225);
  }
  
  // create indicator multi-select interface
  buttonWidth = 500;
  String[] indicators = world.getIndicators();
  
  for (int i=0; i < indicators.length; i++) {
    String indicator = indicators[i];
    GButton current = new GButton(this, xOffset + (i/numRows) * buttonWidth, yOffset + (buttonHeight * (i % numRows)), buttonWidth, buttonHeight, indicator);
    indicatorButtons.add(current);
    current.addEventHandler(this, "countrySelected");
    current.setVisible(false);
  }
  
}

void updateGraphGUIVisibility(boolean switchCategories) {
  boolean toCountries = activeCategoryButton.getText().equals("Indicators") ? true : false;
  ArrayList<GButton> needsToggling = toCountries == true ? indicatorButtons : countryButtons;
  println("on map page? " + onMapPage);
  println("to countries? " + toCountries);
  println("switchCategories? " + switchCategories);
  if (!onMapPage){ 
    if (switchCategories) {
        setVisibility(indicatorButtons, !toCountries);
        setVisibility(countryButtons, toCountries);
        activeCategoryButton = toCountries == true ? countryCategoryButton : indicatorCategoryButton;
        
        indicatorCategoryButton.setLocalColorScheme(toCountries ? GCScheme.BLUE_SCHEME : GCScheme.PURPLE_SCHEME);
        countryCategoryButton.setLocalColorScheme(toCountries ? GCScheme.PURPLE_SCHEME : GCScheme.BLUE_SCHEME);
    }
    else {
      setVisibility(needsToggling, true);
    }
  }
  else {
      setVisibility(needsToggling, false);
  }
}

void setVisibility(ArrayList<GButton> b, boolean visible) {
  for (int i=0; i < b.size(); i++) {
    GButton current = b.get(i);
    current.setVisible(visible);  
  }
}


// helper functions to return Strings (or string arrays) containing selected information in the graph creation screen
String getSelectedChartType() {
  return graphTypes.getSelectedText();
}


int getSelectedYear() {
  return Integer.valueOf(graphYearsList.getSelectedText());
}

String[] getSelectedCountries() {
  ArrayList<String> selected = new ArrayList<String>();
  for (int i=0; i < countryButtons.size(); i++) {
      if (countryButtons.get(i).getLocalColorScheme() == GCScheme.GREEN_SCHEME) {
        selected.add(countryButtons.get(i).getText());  
      }
  }
  Object[] o =  selected.toArray();
  return Arrays.copyOf(o, o.length, String[].class);
}

String[] getSelectedIndicators() {
  ArrayList<String> selected = new ArrayList<String>();
  for (int i=0; i < indicatorButtons.size(); i++) {
      if (indicatorButtons.get(i).getLocalColorScheme() == GCScheme.GREEN_SCHEME) {
        selected.add(indicatorButtons.get(i).getText());  
      }
  }
  Object[] o =  selected.toArray();
  return Arrays.copyOf(o, o.length, String[].class);
}


void GWindowDraw(PApplet app, GWinData data) {
    app.background(255);
    //z.transform();
    activeChart = getSelectedChartType();
    if (activeChart.equals("bar graph") && chart != null) {
      Graphs.drawBarChart(app, chart, 15, 35, 1100, 600);
    }
    else if (activeChart.equals("scatterplot") & graficaPlot != null) {
      Graphs.drawGraficaScatter(app, graficaPlot, 15, 35, 1100, 550);
    }
    else if (activeChart.equals("line graph") & graficaLine != null){
      Graphs.drawGraficaLine(app, graficaLine, 15, 35, 1100, 550);
    }
    else if (activeChart.equals("treemap") && treemap != null) {
      z.transform();
      PVector mousePos = z.getMouseCoord();
      Graphs.drawTreeMap(app, treemap, 15, 35, 1100, 550);  
      if (mousePos.x > 15 && mousePos.x < 1115 && mousePos.y > 35 && mousePos.y < 585) {
        float ratioW = 1100 / ((float) Config.GWIDTH), ratioH = 550 / ((float) Config.GHEIGHT);
        TreeMapNode activeNode = null, root = treemap.getTreeMappa().getRoot();
        for (int i=0; i < root.getChildCount(); i++) {
          activeNode = root.getChildAt(i);
          java.awt.geom.Rectangle2D rect = activeNode.calcGeoBounds();
          if (rectContains(mousePos.x, mousePos.y, (float)(15 + rect.getX()*ratioW), (float)(35 + rect.getY()*ratioH), (float)rect.getWidth() * ratioW, (float)rect.getHeight() * ratioH)) {
            //println("country that contains: " + activeNode.getLabel());
            //println("coords: " + rect.getX() + ", " + rect.getY());
            break;  
          }
        }
        app.textSize((float)(14 * (1.0 /  z.getZoomScale())));
        app.text(activeNode.getLabel() + ": " + ((long)activeNode.getSizeValue()), mousePos.x, mousePos.y);
      }
    }
    else if (activeChart.equals("scatter matrix") && scatterMatrix != null) {
      Graphs.drawScatterMatrix(app, scatterMatrix, getSelectedIndicators(), 0, 35, app.width -100, 550);
    }
    
    app.fill(0);
    app.textSize(14);
    app.textAlign(LEFT,BOTTOM);
    app.text(Integer.toString(currentChartYear), 568, 30);
}

void GKeyHandler(PApplet app, GWinData data, KeyEvent k) {
  if (k.getKey() == 'r') {
    z.reset();  
  }
}
// drag-select implementation

void mousePressed() {
  dragAreaX = mouseX;
  dragAreaY = mouseY;
}

void mouseDragged() {
  shouldDrawDragArea = true;
  dragWidth = mouseX - dragAreaX;
  dragHeight = mouseY - dragAreaY;
}

void mouseReleased() {
  if (shouldDrawDragArea == true) {
    toggleSelectedCountries(mouseX, mouseY, mouseButton == LEFT);  
  }
  shouldDrawDragArea = false;
}

void drawDragArea() {
  fill(dragAreaFill);
  rect(dragAreaX, dragAreaY, dragWidth, dragHeight);
}

void toggleSelectedCountries(int lastX, int lastY, boolean selected) {
  if (onMapPage) {
   return; 
  }
    
  int r1X = min(lastX, dragAreaX), r1Y = min(lastY, dragAreaY),
  r1Width = abs(lastX - dragAreaX), r1Height = abs(lastY - dragAreaY);
  for (int i=0; i < countryButtons.size(); i++) {
    GButton b = countryButtons.get(i);
    float bX = b.getX(), bY = b.getY(), bWidth = b.getWidth(), bHeight = b.getHeight();
    
    if (rectOverlap(r1X, r1Y, r1Width, r1Height, bX, bY, bWidth, bHeight)) {
      toggleButtonState(b, selected);  
    }
  }
}

void toggleButtonState(GButton button, boolean selected) {
  if (!selected) {
    button.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  }
  else {
    button.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  }
}


boolean rectOverlap(float r1X, float r1Y, float r1Width, float r1Height, float r2X, float r2Y, float r2Width, float r2Height) {
   //return x < r.x + r.width && x + width > r.x && y < r.y + r.height && y + height > r.y;
   return r1X < r2X + r2Width && r1X + r1Width > r2X && r1Y < r2Y + r2Height && r1Y + r1Height > r2Y;
}

boolean rectContains(float x, float y, float rX, float rY, float rWidth, float rHeight) {
    return (x > rX && x < rX + rWidth && y > rY && y < rY + rHeight); 
  }