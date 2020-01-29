import java.util.Arrays;

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
  
  ArrayList<Float> getIndicatorValues(String indicator) {
      if (dataMap.containsKey(indicator)) {
        return (ArrayList<Float>)dataMap.get(indicator);
      }
      return null;
  }
  
  Float getIndicatorValue(String indicator, int year) {
    ArrayList<Float> indicatorValues = getIndicatorValues(indicator);
    if (indicatorValues == null || year < START_YEAR) {
      return new Float(-1);  
    }
    //Makes a gross 
    return indicatorValues.get(year - START_YEAR);    
  }
  
}