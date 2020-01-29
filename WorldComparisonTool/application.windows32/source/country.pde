class Country {
   PShape components;
   String name;
   Data data;
   color fill;
   
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
   
   String getName() {
     return name; 
   }
   
   Data getData() {
     return data;     
   }
   
   boolean contains(int x, int y) {
     for (int i=0; i < components.getChildCount(); i++) {
       if (polyContains(components.getChild(i),x,y)) {
         return true; 
       }
     }
     return false;
   }
   
   void setFill(color c) {
     for (int i=0; i < components.getChildCount(); i++) {
       PShape current = components.getChild(i);
       current.getChild(0).setFill(c);
     }
   }
}