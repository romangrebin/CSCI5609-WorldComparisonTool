PShape parseShapeFromCoords(JSONArray polygon) {
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

float scale(float x, float xmin, float xmax, float ymin, float ymax) {
   return ymin + (ymax - ymin) * (x - xmin) / (xmax - xmin); 
}

float logScale(double x, double xmin, double xmax, double ymin, double ymax) {
  return (float) (ymin + ((Math.log10(x) - Math.log10(xmin)) / (Math.log10(xmax) - Math.log10(xmin))) * (ymax - ymin));
}

float magnitudeDifference(double a, double b) {
   return (float) Math.abs(Math.log10(a) - Math.log10(b)); 
}
// source: https://github.com/substack/point-in-polygon/blob/master/index.js
Boolean polyContains(PShape parent, int x, int y) {
    
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