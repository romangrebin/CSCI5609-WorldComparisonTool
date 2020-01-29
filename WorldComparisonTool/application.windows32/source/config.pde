static class Config {
  static color gradientStart = #FFFFFF, 
               gradientEnd = #8B4513,
               defaultFill = #202020;
               
  static int START_YEAR = 1997, END_YEAR = 2014;
  static int GWIDTH = 1260, GHEIGHT = 700;
  static String[] getYears() {
    String[] years = new String[END_YEAR - START_YEAR + 1];
    
    for (int i=0; i < years.length; i++) {
      years[i] = Integer.toString(1997 + i);  
    }
    return years;
  }
  
  static int COUNTRY_ID_LOWER_BOUND = 13000;
  
  static String [] chartTypes = {"scatterplot", "bar graph", "treemap", "line graph", "scatter matrix"};
}