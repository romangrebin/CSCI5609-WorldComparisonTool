


void test(CountryDatabase countries) {
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