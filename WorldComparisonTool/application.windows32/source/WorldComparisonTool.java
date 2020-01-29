import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import g4p_controls.*; 
import grafica.*; 
import org.gicentre.utils.stat.*; 
import org.gicentre.utils.move.*; 
import org.gicentre.treemappa.*; 
import org.gicentre.utils.colour.*; 
import java.util.Arrays; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class WorldComparisonTool extends PApplet {






      // For treemappa classes
   // Colours needed by treemappa.
//import java.awt.event.KeyEvent; 

//GButton testing;

// variables to assist with drag-select functionality
int dragAreaX = 0, dragAreaY = 0, dragWidth = 0, dragHeight = 0;
boolean shouldDrawDragArea = false;
int dragAreaFill = color(50,0,255,100);

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

public void settings() {
  this.size(1280, 700);  
}
public void setup() {
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


  
public int randomColor() {
  int c = color(random(255), random(255), random(255));
  return c;
}


// Main draw function ------------------------------------------ Main draw function
public void draw() {  
  this.background(240,240,240);
  //z.transform();
  
  if (onMapPage) {
    world.draw();
    drawMapPageText();
    drawMapLegend();
    if (playingMapYears) {
      // Change the pace of auto-advancing by changing the mod number
      framesSinceAdvancing = (framesSinceAdvancing + 1) % 10;
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
public void mapListModified(GDropList list, GEvent event) {
  
  //___________________________ Remake the chart with the new indicator
  //chart = Graphs.createBarChart(this, world, selectedIndicator, 2005);
  //plot = Graphs.createScatterPlot(this, world, selectedIndicator, "Population total", 2005);
  //graficaPlot = Graphs.createGraficaScatter( this, world, selectedIndicator, "Population total", 2005);
  //___________________________

}



public void categoryButtonClicked(GButton button, GEvent event) {
  if (button == activeCategoryButton) {
    return;  
  }
  updateGraphGUIVisibility(true);
}



// this is the function where you will change the various graph / chart / plot objects you've created. 
public void createGraphButtonClicked(GButton button, GEvent event) {
  win.setVisible(true);  ///_________________________
  currentChartYear = getSelectedYear(); 
  recreateGraphs();
}

// remake graphs based on new information
public void recreateGraphs() {  
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

public void countrySelected(GButton button, GEvent event) {
  if (button.getLocalColorScheme() == GCScheme.BLUE_SCHEME) {
    button.setLocalColorScheme(GCScheme.GREEN_SCHEME); 
  }
  else {
    button.setLocalColorScheme(GCScheme.BLUE_SCHEME);   
  }
}

public void chartNextYearHandler(GButton button, GEvent event) {
  if (currentChartYear == Config.END_YEAR) {
    currentChartYear = Config.START_YEAR;
  }
  else {
    currentChartYear++;
  }
  recreateGraphs();
}

public void chartPrevYearHandler(GButton button, GEvent event) {
  if (currentChartYear == Config.START_YEAR) {
    currentChartYear = Config.END_YEAR;
  }
  else {
    currentChartYear--;
  }
  recreateGraphs();
}

public void applyButtonHandler(GButton button, GEvent event) {
  world.applyIndicator(indicatorList.getSelectedText(), Integer.parseInt(yearList.getSelectedText()), logCheck.isSelected());
}

public void playMapHandler(GButton button, GEvent event) {
  if (playingMapYears) {
    button.setText("Auto-Advance");
  }
  else {
    button.setText("Pause");
  }
  playingMapYears = !playingMapYears;
}


public void redirectButtonHandler(GButton button, GEvent event) {
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

public void drawMainGUI() {
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
 
public void drawMapPageText() {
    this.textSize(12);
    this.text("Indicators: ", 135, 52);
    this.text("Years: ", 560, 52);
}

public void drawMapLegend() {
  textAlign(LEFT);
  
  // No data, black rectangle
  fill(0);
  rect(80, 450, 20, 20);
  text("No data", 105, 465);
  
  int c1 = Config.gradientEnd;
  int c2 = Config.gradientStart;
  
  for (int y = 500; y <= 650; y++) {
    float mappedVal = map(y, 500, 650, 0, 1);
    int c = lerpColor(c1, c2, mappedVal);
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
    float temp = (float)((.75f* (Math.log10(world.maxValue) - Math.log10(world.minValue))) + Math.log10(world.minValue));
    val34 =  pow(10, temp);
    
    temp = (float)((.5f* (Math.log10(world.maxValue) - Math.log10(world.minValue))) + Math.log10(world.minValue));
    val12 = pow(10, temp);
    
    temp = (float)((.25f* (Math.log10(world.maxValue) - Math.log10(world.minValue))) + Math.log10(world.minValue));
    val14 = pow(10, temp);
  }
  else {
    val34 = map(.75f, 0, 1, world.minValue, world.maxValue);
    val12 = map(.5f, 0, 1, world.minValue, world.maxValue);
    val14 = map(.25f, 0, 1, world.minValue, world.maxValue);
  }
  
  text(Float.toString(val34), 105, 542);
  text(Float.toString(val12), 105, 580);
  text(Float.toString(val14), 105, 617);
  
}

public void drawGraphCreatorPageText() {
    this.textSize(16);
    this.text("Graph Creator", 320, 37);
    this.textSize(12);
    this.text("Graph Type: ", 990, 93);
    this.text("Year: ", 990, 213);
}

public void initGraphGUI() {
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

public void updateGraphGUIVisibility(boolean switchCategories) {
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

public void setVisibility(ArrayList<GButton> b, boolean visible) {
  for (int i=0; i < b.size(); i++) {
    GButton current = b.get(i);
    current.setVisible(visible);  
  }
}


// helper functions to return Strings (or string arrays) containing selected information in the graph creation screen
public String getSelectedChartType() {
  return graphTypes.getSelectedText();
}


public int getSelectedYear() {
  return Integer.valueOf(graphYearsList.getSelectedText());
}

public String[] getSelectedCountries() {
  ArrayList<String> selected = new ArrayList<String>();
  for (int i=0; i < countryButtons.size(); i++) {
      if (countryButtons.get(i).getLocalColorScheme() == GCScheme.GREEN_SCHEME) {
        selected.add(countryButtons.get(i).getText());  
      }
  }
  Object[] o =  selected.toArray();
  return Arrays.copyOf(o, o.length, String[].class);
}

public String[] getSelectedIndicators() {
  ArrayList<String> selected = new ArrayList<String>();
  for (int i=0; i < indicatorButtons.size(); i++) {
      if (indicatorButtons.get(i).getLocalColorScheme() == GCScheme.GREEN_SCHEME) {
        selected.add(indicatorButtons.get(i).getText());  
      }
  }
  Object[] o =  selected.toArray();
  return Arrays.copyOf(o, o.length, String[].class);
}


public void GWindowDraw(PApplet app, GWinData data) {
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
      Graphs.drawTreeMap(app, treemap, 15, 35, 1100, 550);  
      //Graphs.drawTreeMap(app, treemap, -1, -1, -1, -1);
    }
    else if (activeChart.equals("scatter matrix") && scatterMatrix != null) {
      Graphs.drawScatterMatrix(app, scatterMatrix, getSelectedIndicators(), 0, 35, app.width -100, 550);
      //Graphs.drawTreeMap(app, treemap, -1, -1, -1, -1);
    }
    
    app.fill(0);
    app.textSize(14);
    app.textAlign(LEFT,BOTTOM);
    app.text(Integer.toString(currentChartYear), 568, 30);
}

public void GKeyHandler(PApplet app, GWinData data, KeyEvent k) {
  if (k.getKey() == 'r') {
    z.reset();  
  }
}
// drag-select implementation

public void mousePressed() {
  dragAreaX = mouseX;
  dragAreaY = mouseY;
}

public void mouseDragged() {
  shouldDrawDragArea = true;
  dragWidth = mouseX - dragAreaX;
  dragHeight = mouseY - dragAreaY;
}

public void mouseReleased() {
  if (shouldDrawDragArea == true) {
    toggleSelectedCountries(mouseX, mouseY, mouseButton == LEFT);  
  }
  shouldDrawDragArea = false;
}

public void drawDragArea() {
  fill(dragAreaFill);
  rect(dragAreaX, dragAreaY, dragWidth, dragHeight);
}

public void toggleSelectedCountries(int lastX, int lastY, boolean selected) {
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

public void toggleButtonState(GButton button, boolean selected) {
  if (!selected) {
    button.setLocalColorScheme(GCScheme.BLUE_SCHEME);
  }
  else {
    button.setLocalColorScheme(GCScheme.GREEN_SCHEME);
  }
}


public boolean rectOverlap(float r1X, float r1Y, float r1Width, float r1Height, float r2X, float r2Y, float r2Width, float r2Height) {
   //return x < r.x + r.width && x + width > r.x && y < r.y + r.height && y + height > r.y;
   return r1X < r2X + r2Width && r1X + r1Width > r2X && r1Y < r2Y + r2Height && r1Y + r1Height > r2Y;
}

class CountryDatabase {
  PShape countryShapes;
  ArrayList<Country> countries;
  String selectedIndicator;
  int selectedYear;
  boolean logScale;
  float minValue, maxValue;
  
  CountryDatabase(String jsonFile) {
    selectedIndicator = "none";
    JSONObject json = loadJSONObject(jsonFile);
    JSONArray coordList = json.getJSONArray("features");
    countryShapes = createShape(GROUP);
    countries = new ArrayList<Country>();
    
    logScale = false;
    
    minValue = 0;
    maxValue = 0;
    
    for (int i=0; i < coordList.size(); i++) {
      JSONObject current = coordList.getJSONObject(i);
      Country c = new Country(current);
      println(c.name);
      countries.add(c);
      countryShapes.addChild(c.components);
    }
    
  }
  
  public Country getCountry(String name) {
    for (int i=0; i < countries.size(); i++) {
       if (countries.get(i).getName().equals(name)) {
         return countries.get(i); 
       }
    }
    return null;
  }
  
  public void applyIndicator(String indicator, int year, boolean isLog) {
      if (indicator.equals(selectedIndicator) && year == selectedYear) {
        return;  
      }
      
      logScale = isLog;
      Pair range = getIndicatorValueRange(indicator, year);
      minValue = range.min;
      maxValue = range.max;
      //boolean linearScale = magnitudeDifference(range.min, range.max) <= 2.5;
      println("linearScale status: " + !logScale);
      println("---BEGIN INDICATOR VALUE DUMP (ORIGINAL/SCALED)---");
      for (int i=0; i < countries.size(); i++) {
        Country c = countries.get(i);
        float val  = c.data.getIndicatorValue(indicator, year).floatValue();
        int fill = Config.defaultFill;
        println("Country: " + c.getName());
        println("\toriginal: " + val);
        if (val > 0) {
          float v;
          if (!logScale) {
            v = scale(val, minValue, maxValue, 0, 1);
          }
          else {
            v = logScale(val, minValue, maxValue, 0, 1);
          }
          println("\tscaled: " + v);
          fill = lerpColor(Config.gradientStart, Config.gradientEnd, v);
        }
        c.setFill(fill);
      }
      println("---END INDICATOR VALUE DUMP (ORIGINAL/SCALED)---");
      println("Selected Indicator: " + indicator);
      println("minimum value: " + minValue);
      println("maximum value: " + maxValue);
      
  }
  
  public Pair getIndicatorValueRange(String indicator, int year) {
    Pair p = new Pair();
    for (int i=0; i < countries.size(); i++) {
      float val = countries.get(i).data.getIndicatorValue(indicator, year);
      if (val >= 0) {
        if (val < p.min) {
          p.min = val;  
        }
        if (val > p.max) {
          p.max = val; 
        }
      }
    }
    return p;
  }
  
  
  public String[] getIndicators() {
    if (world != null && (world.countries.size() > 0)) {
      Country c = world.countries.get(0);
      Object[] o =  c.data.dataMap.keySet().toArray();
      return Arrays.copyOf(o, o.length, String[].class);
    }
    return null;
  }
  
  public void draw() {
    shape(countryShapes); 
  }
}
static class Config {
  static int gradientStart = 0xffFFFFFF, 
               gradientEnd = 0xff8B4513,
               defaultFill = 0xff202020;
               
  static int START_YEAR = 1997, END_YEAR = 2014;
  static int GWIDTH = 1260, GHEIGHT = 700;
  public static String[] getYears() {
    String[] years = new String[END_YEAR - START_YEAR + 1];
    
    for (int i=0; i < years.length; i++) {
      years[i] = Integer.toString(1997 + i);  
    }
    return years;
  }
  
  static int COUNTRY_ID_LOWER_BOUND = 13000;
  
  static String [] chartTypes = {"scatterplot", "bar graph", "treemap", "line graph", "scatter matrix"};
}
class Country {
   PShape components;
   String name;
   Data data;
   int fill;
   
   Country(JSONObject json) {
       fill = 255;
       components = createShape(GROUP);
       
       String dataFile = "../data/Data.csv"; // relative path to the worldbank Data file
       String dataFileContents[] = loadStrings(dataFile);
       
       name = json.getJSONObject("properties").getString("ADMIN");
       JSONObject geometry = json.getJSONObject("geometry");
       JSONArray polygon = geometry.getJSONArray("coordinates");
       
       data = new Data(name, dataFileContents);
       
       if (geometry.getString("type").equals("Polygon")) {
         components.addChild(parseShapeFromCoords(polygon));
       }
       else {
         for (int i=0; i < polygon.size(); i++) {
            components.addChild(parseShapeFromCoords(polygon.getJSONArray(i)));
         }
       }
   }
   
   public String getName() {
     return name; 
   }
   
   public Data getData() {
     return data;     
   }
   
   public boolean contains(int x, int y) {
     for (int i=0; i < components.getChildCount(); i++) {
       if (polyContains(components.getChild(i),x,y)) {
         return true; 
       }
     }
     return false;
   }
   
   public void setFill(int c) {
     for (int i=0; i < components.getChildCount(); i++) {
       PShape current = components.getChild(i);
       current.getChild(0).setFill(c);
     }
   }
}


int COUNTRY_COLUMN = 0;
int INDICATOR_COLUMN = 2;
int START_YEAR_COLUMN = 4;
int START_YEAR = 1997;

class Data {
  HashMap dataMap;
  
  Data(String countryName, String fileContents[]) {
    
    dataMap = new HashMap();
    // For each row in the file
    for (int rowNum = 0; rowNum < fileContents.length; rowNum++){
      // If this row contains data for the current countryName
      if (fileContents[rowNum].contains(countryName))
      {
        // Array of the values in different columns in the row
        String[] row = split(fileContents[rowNum], ","); 
        
        // Get the name of the indicator in this row
        String indicatorName = row[INDICATOR_COLUMN];
        ArrayList<Float> indicatorData = new ArrayList<Float>();
        
        // For each year, add the value to indicatorData
        for (int i = START_YEAR_COLUMN; i < row.length; i++) {
          if (!row[i].contains("..")) {
            indicatorData.add(Float.parseFloat(row[i]));
          }
          else {
            indicatorData.add(new Float(-1));
          }
        }
        // map indicatorName to indicatorData
        dataMap.put(indicatorName, indicatorData);
      }
    }
    if (dataMap.isEmpty()) {
      // Hopefully this is never reached
      println("No data found for " + countryName);
    }
  }
  
  public ArrayList<Float> getIndicatorValues(String indicator) {
      if (dataMap.containsKey(indicator)) {
        return (ArrayList<Float>)dataMap.get(indicator);
      }
      return null;
  }
  
  public Float getIndicatorValue(String indicator, int year) {
    ArrayList<Float> indicatorValues = getIndicatorValues(indicator);
    if (indicatorValues == null || year < START_YEAR) {
      return new Float(-1);  
    }
    //Makes a gross 
    return indicatorValues.get(year - START_YEAR);    
  }
  
}
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
  public static BarChart createBarChart(PApplet parent, CountryDatabase world, String indicator, int year, String[] countryNames) {
    
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
  public static XYChart createScatterPlot(PApplet parent, CountryDatabase world, String xIndicator, String yIndicator, int year, String[] countryNames) {
    
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
  public static GPlot createGraficaScatter(PApplet parent, CountryDatabase world, String xIndicator, String yIndicator, int year, String[] countryNames) {
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
  public static GPlot createGraficaLine(WorldComparisonTool worldTool, PApplet parent, CountryDatabase world, String indicator, String[] countryNames) {
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
  
  public static GPlot[] createScatterMatrix(PApplet parent, CountryDatabase world, String[] indicators, int year, String[] countryNames) {
    
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
  
  public static PTreeMappa createTreeMap(PApplet parent, CountryDatabase world, String indicator, String[] countryNames, int year){
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
  
  public static void drawTreeMap(PApplet parent, PTreeMappa treemap, int xpos, int ypos, int xdim, int ydim) {
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
  public static void drawBarChart(PApplet parent, BarChart chart, int xpos, int ypos, int xdim, int ydim) {
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
  public static void drawScatterPlot(PApplet parent, XYChart plot, int xpos, int ypos, int xdim, int ydim) {
    // Make background for the chart
    parent.stroke(255);
    parent.fill(255);
    parent.rect(xpos, ypos, xdim, ydim);
    
    parent.textSize(14);
    
    plot.draw(xpos, ypos, xdim, ydim);
  }
  
  // Draws grafica ScatterPlot returned from createGraficaScatter function (GRAFICA!)
  public static void drawGraficaScatter(PApplet parent, GPlot plot, int xpos, int ypos, int xdim, int ydim) {
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
  
  public static void drawGraficaLine(PApplet parent, GPlot plot, int xpos, int ypos, int xdim, int ydim) {
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
  
  public static void drawScatterMatrix(PApplet parent, GPlot[] plots, String[] indicatorNames, int xmin, int ymin, int xdim, int ydim) {
    parent.textSize(8);
    parent.textAlign(LEFT,TOP);
    // For each row in the scatterplot matrix
    for (int i = 0; i < indicatorNames.length; i++) {
      // Add row indicator name
      //println(indicatorNames[i]);
      parent.text(Integer.toString(i + 1) + ".", xmin + 25, ymin + (i + 1)*(ydim / indicatorNames.length));
      // Add column indicator name
      parent.text(Integer.toString(i + 1) + ". " + indicatorNames[i], xmin + (i+.5f)*(xdim / indicatorNames.length), ymin + 15);
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
  
  

  public static boolean rectContains(float x, float y, float rX, float rY, float rWidth, float rHeight) {
    return (x > rX && x < rX + rWidth && y > rY && y < rY + rHeight); 
  }
}
class Pair {
  public float min, max;
  
  Pair() {
    min = (float) Double.MAX_VALUE;
    max = 0;
  } 
}



public void test(CountryDatabase countries) {
  final int NAME_COL = 0, INDICATOR_COL = 1, YEAR_COL = 2, VALUE_COL = 3;
  String [] testLines = loadStrings("test.txt");
  for (int i=0; i < testLines.length; i++) {
     String [] currentTest = split(testLines[i],",");
     String countryName = currentTest[NAME_COL], indicator = currentTest[INDICATOR_COL];
     int year = Integer.parseInt(currentTest[YEAR_COL]);
     Double val = Double.parseDouble(currentTest[VALUE_COL]);
     Country c = countries.getCountry(countryName);
     //println("size of " + countryName + "'s dataMap: " + c.data.dataMap.size());
     //Object[] keys = c.data.dataMap.keySet().toArray();
     //for (int j=0; j < keys.length; j++) {
     //   println("||" + ((String)keys[j]) + "||"); 
     //}
     ArrayList<Double> data = (ArrayList<Double>) c.data.dataMap.get(indicator);
     if (data == null) {
       println("couldn't get data for indicator: " + indicator); 
     }
     println("-----TESTING------");
     println("Country: " + countryName);
     println("Indicator: " + indicator);
     println("Year: " + year);
     println("Expected output: " + val);
     println("Actual output: " + data.get(year - 1997));
     println();
  }
}
public PShape parseShapeFromCoords(JSONArray polygon) {
   PShape p = createShape(GROUP);
   for (int i = 0; i < polygon.size(); i++) {
     JSONArray coords = polygon.getJSONArray(i); 
     PShape child = createShape();
     child.beginShape();
     for (int j=0; j < coords.size(); j++) {
        if (j % 15 != 0)
          continue;
        JSONArray coord = coords.getJSONArray(j);
        float x = scale(coord.getFloat(0), -180, 180, 0, 1280) /*- 200*/;
        float y = scale(coord.getFloat(1), 90, -90, 0, 700) + 50;
        
        child.vertex(x, y);
     }
     child.endShape();
     p.addChild(child);
   }
   return p;
}

public float scale(float x, float xmin, float xmax, float ymin, float ymax) {
   return ymin + (ymax - ymin) * (x - xmin) / (xmax - xmin); 
}

public float logScale(double x, double xmin, double xmax, double ymin, double ymax) {
  return (float) (ymin + ((Math.log10(x) - Math.log10(xmin)) / (Math.log10(xmax) - Math.log10(xmin))) * (ymax - ymin));
}

public float magnitudeDifference(double a, double b) {
   return (float) Math.abs(Math.log10(a) - Math.log10(b)); 
}
// source: https://github.com/substack/point-in-polygon/blob/master/index.js
public Boolean polyContains(PShape parent, int x, int y) {
    
    boolean innerRing = true;
    for (int k=0; k < parent.getChildCount(); k++) {
      innerRing = !innerRing;
      PShape p = parent.getChild(k);
      Boolean inside = false;
      for (int i = 0, j = p.getVertexCount() - 1; i < p.getVertexCount(); j = i++) {
          float xi = p.getVertex(i).x, yi = p.getVertex(i).y;
          float xj = p.getVertex(j).x, yj = p.getVertex(j).y;
          
          Boolean intersect = ((yi > y) != (yj > y))
              && (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
          if (intersect) inside = !inside;
      }
      if ((inside && innerRing) || (!inside && !innerRing)) { 
        return false;
      }
    }
    return true;
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "WorldComparisonTool" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
