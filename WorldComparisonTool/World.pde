
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
  
  Country getCountry(String name) {
    for (int i=0; i < countries.size(); i++) {
       if (countries.get(i).getName().equals(name)) {
         return countries.get(i); 
       }
    }
    return null;
  }
  
  void applyIndicator(String indicator, int year, boolean isLog) {
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
        color fill = Config.defaultFill;
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
  
  Pair getIndicatorValueRange(String indicator, int year) {
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
  
  
  String[] getIndicators() {
    if (world != null && (world.countries.size() > 0)) {
      Country c = world.countries.get(0);
      Object[] o =  c.data.dataMap.keySet().toArray();
      return Arrays.copyOf(o, o.length, String[].class);
    }
    return null;
  }
  
  void draw() {
    shape(countryShapes); 
  }
}