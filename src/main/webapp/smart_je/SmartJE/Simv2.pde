// Vehicles simulator
// Carlos Gil 12/2013

JSystem JSys;

float Jslsz;  // Lane scale !!!!
boolean DebugMode = false;

int NV = 0;
SimulT Simd = new SimulT();

//TrafficLight[] Tl = new TrafficLight[5];
FastRandom Rd = new FastRandom();


void ToggleDebugMode()
{
  if ( DebugMode )
    DebugMode = false;
  else
    DebugMode = true;
}

void ToggleBirdEye()
{
  if ( BirdEye )
  {
    Scale = 1;
    BirdEye = false;
  }
  else
  {
    Scale = 0.250;
    BirdEye = true;
  }
}

// Simulation data
class SimulT
{
  int startm;  // Start millisecond from las step
  int accumm;  // Accumulated millisecond steps from simulation begining
  int speed;   // Simulation speed
  
  SimulT()
  {
    startm = 0;
    accumm = 0;
    speed = 1;
  }
  
  void init()
  {
    startm = millis();
    accumm = 0;
    speed = 1;
    NV = 0;
  }
  
  // Accumulates millisecons for simulation step at a given simulation speed
  void step()
  {
    int ms = millis();
    accumm += (ms - startm)*speed;
    startm = ms;
  }
  
  // Returns accumulated msec from simulation start
  int msec()
  {
    int ms = (millis() - startm)*speed + accumm;

    return(ms);
  }
  
  // Duplicates simulation speed
  void speedUp()
  {
    if ( speed < 1024 )
    {
      step();
      speed <<= 1;
    }
  }
  
  // Halves simulation speed
  void speedDown()
  {
    // Slow down simulation
    if ( speed > 1 )
    {
      step();
      speed >>= 1;
    }
  }
  
  // Displays actual time
  void display(int end)
  {
    pushStyle();
    textSize(24);
    textAlign(LEFT, CENTER);
  
    int msec = (end - startm)*speed + accumm;
    int days = int(msec/86400000);
    int hours = msec%86400000;
    int mins = hours%3600000;
    int secs = int((mins%60000)/1000);  // $$$
    hours = int(hours/3600000);  // $$$
    mins = int(mins/60000);  // $$$
  
    String s = speed+"x  "+days+"d "+hours+"h "+mins+"m "+secs+"s";
    if ( CPULimit )
      fill(255,0,0);
    else
      fill(0,255,0);

    if ( Mode3D )
      text(s,20,40,1);
    else
      text(s,20,40);
    
    popStyle();
  }
}

// Fast random number generator
// Returns a Gaussian random number between -1 and 1 (close to 0 means more frequent)
class FastRandom
{
  float[] gr;
  int seed;
  
  FastRandom()
  {
    // Initializes array of gaussian distributed random numbers (-1 < r < 1)
    gr = new float[1009];
    for ( int i=0 ; i<1009 ; i++ )
    {
      float r = randomGaussian();
      if ( r > 0 )
        gr[i] = 1 - 1/(1+r);
      else
        gr[i] = -(1 - 1/(1-r));
    }
    
    seed = int(random(0,1009));
  }
  
  // Returns a random number between -1 and 1 based on gaussian distribution
  float gauss()
  {
    int s = seed;
    seed += 3;
    if ( seed >= 1009 )
      seed -= 1009;
      
    return(gr[s]);
  }
}


// Point class
class Point
{
  float x;
  float y;
  
  Point(float x, float y)
  {
    this.x = x;
    this.y = y;
  }
  
  void set(float x, float y)
  {
    this.x = x;
    this.y = y;
  }
}

// Cross point relative to two segments or curves
class CrossPoint
{
  float ofs1;
  float ofs2;
  float sen;
  float x;
  float y;
  
  CrossPoint(float o1, float o2, float s)
  {
    ofs1 = o1;
    ofs2 = o2;
    sen = s;
  }

  void setXY(float x, float y)
  {
    this.x = x;
    this.y = y;
  }
}

// Segment class
class Segment
{
  Point pi;
  Point pf;
  float m;
  
  Segment(Point i, Point f)
  {
    pi = new Point(i.x,i.y);
    pf = new Point(f.x,f.y);
    if ( i.x != f.x )
      m = (f.y - i.y)/(f.x - i.x);
    else
      m = 0x7FFFFFFF;  // Infinite
  }
  
  // Set segment points
  void set(Point i, Point f)
  {
    pi.x = i.x;
    pi.y = i.y;
    pf.x = f.x;
    pf.y = f.y;
    if ( i.x != f.x )
      m = (f.y - i.y)/(f.x - i.x);
    else
      m = 0x7FFFFFFF;  // Infinite
  }
  
  // Segment length
  float len()
  {
    float l = dist(pi.x,pi.y,pf.x,pf.y);
    return(l);
  }
  
  // Determines cross point with another segment
  // Returs offset to the cross point or -1 if no crossing point
  CrossPoint cross(Segment s)
  {
    float diix, diiy, dii;
    float difx, dify, dif;
    float dfix, dfiy, dfi;
    float dffx, dffy, dff;
    float ms;
    
    if ( s.pi.x != s.pf.x )
      ms = (s.pf.y - s.pi.y)/(s.pf.x - s.pi.x);
    else
      ms = 0x7FFFFFFF;  // Infinite
    
    float d = sqrt(sq(pf.x - pi.x) + sq(pf.y - pi.y));
    float ds = sqrt(sq(s.pf.x - s.pi.x) + sq(s.pf.y - s.pi.y));
    if ( m == ms )
    {
      // Parallel segments, may overlap
      // Checks segments ends
      diix = s.pi.x - pi.x;
      diiy = s.pi.y - pi.y;
      dii = sqrt(diix*diix + diiy*diiy);
      dfix = s.pi.x - pf.x;
      dfiy = s.pi.y - pf.y;
      dfi = sqrt(dfix*dfix + dfiy*dfiy);
      if ( abs(d - (dii + dfi)) < 0.1 )
        return(new CrossPoint(dii,0,0));

      difx = s.pf.x - pi.x;
      dify = s.pf.y - pi.y;
      dif = sqrt(difx*difx + dify*dify);
      dffx = s.pf.x - pf.x;
      dffy = s.pf.y - pf.y;
      dff = sqrt(dffx*dffx + dffy*dffy);
      if ( abs(d - (dif + dff)) < 0.1 )
        return(new CrossPoint(dif,ds,0));

      if ( abs(ds - (dii + dif)) < 0.1 )
        return(new CrossPoint(0,dif,0));

      if ( abs(ds - (dfi + dff)) < 0.1 )
        return(new CrossPoint(d,dfi,0));
      
      return(null);
    }

    // Crossing lines
    float x = ((m*pi.x - ms*s.pi.x) - (pi.y - s.pi.y))/(m - ms);
    float y = m*(x-pi.x) + pi.y;

    diix = x - pi.x;
    diiy = y - pi.y;
    dii = sqrt(diix*diix + diiy*diiy);
    dfix = x - pf.x;
    dfiy = y - pf.y;
    dfi = sqrt(dfix*dfix + dfiy*dfiy);
    difx = x - s.pi.x;
    dify = y - s.pi.y;
    dif = sqrt(difx*difx + dify*dify);
    dffx = x - s.pf.x;
    dffy = y - s.pf.y;
    dff = sqrt(dffx*dffx + dffy*dffy);
    if ( (abs(d - (dii + dfi)) < 0.1) && (abs(ds - (dif + dff)) < 0.1) )
    {
      float sen = (pf.x-pi.x)*(s.pf.y-s.pi.y) - (pf.y-pi.y)*(s.pf.x-s.pi.x);
      return(new CrossPoint(dii,dif,sen));
    }

    return(null);
  }

  // Checks if point near a segment (distance < r), returns offset or -1
  float near(Point p, float r)
  {
    float pipx = p.x - pi.x;
    float pipy = p.y - pi.y;
    float pipfx = pf.x - pi.x;
    float pipfy = pf.y - pi.y;
    float pipf = sqrt(pipfx*pipfx + pipfy*pipfy);
    float h = abs(pipx*pipfy - pipy*pipfx)/pipf;
    float l = (pipx*pipfx + pipy*pipfy)/pipf;
    println("Near ("+p.x+","+p.y+") -> ("+pi.x+","+pi.y+") : ("+pf.x+","+pf.y+") => H:"+h+" , L:"+l);
    if ( h > r )
      return(-1);
    
    if ( (l < 0) || (l > pipf) )
      return(-1);
    
    return(l);
  }
  
  // X/Y Projection overlap between two segments (rectangle)
  // Returns 0:No overlap, 1:Partial overlap, 2:Full overlap
  int projectionX(Segment s, float w)
  {
    PVector u = new PVector((pf.x-pi.x),(pf.y-pi.y));
    PVector v = new PVector((s.pf.x-s.pi.x),(s.pf.y-s.pi.y));
    PVector p = new PVector((s.pi.x-pi.x),(s.pi.y-pi.y));
    float xi, xf;
    
    float l = u.mag();
    u.normalize();
    float vpx = v.x*u.x + v.y*u.y;
    float wpx = w*sqrt(1 - sq(abs(vpx)/v.mag()))/2;
    float xo = p.x*u.x + p.y*u.y;
    if ( vpx > 0 )
    {
      xi = xo - wpx;
      xf = xo + vpx + wpx;
    }
    else
    {
      xi = xo + vpx - wpx;
      xf = xo + wpx;
    }
    
    if ( (xi < l) && (xf > 0) )
    {
      // Overlaps
      if ( (xi >= 0) && (xf <= l) )
      {
        // Full overlap
        return(2);
      }
      
      return(1);
    }
    
    return(0);
  }

  int projectionY(Segment s, float w)
  {
    PVector u = new PVector(-(pf.y-pi.y),(pf.x-pi.x));
    PVector v = new PVector((s.pf.x-s.pi.x),(s.pf.y-s.pi.y));
    PVector p = new PVector((s.pi.x-pi.x),(s.pi.y-pi.y));
    float yi, yf;
    
    u.normalize();
    float vpy = v.x*u.x + v.y*u.y;
    float wpy = w*sqrt(1 - sq(abs(vpy)/v.mag()))/2;
    float yo = p.x*u.x + p.y*u.y;
    if ( vpy > 0 )
    {
      yi = yo - wpy;
      yf = yo + vpy + wpy;
    }
    else
    {
      yi = yo + vpy - wpy;
      yf = yo + wpy;
    }
    
    if ( (yi < w/2) && (yf > -w/2) )
    {
      // Overlaps
      if ( (yi >= -w/2) && (yf <= w/2) )
      {
        // Full overlap
        return(2);
      }
      
      return(1);
    }
    
    return(0);
  }

  // Checks if two thick segments or rectangles (width w) overlap
  boolean overlap(Segment s, float w)
  {
    int gpx = projectionX(s,w);
    int gpy = projectionY(s,w);
    if ( (gpx > 0) && (gpy > 0) )
    {
      // May overlap
      if ( (gpx != 2) && (gpy != 2) )
      {
        int spx = s.projectionX(this,w);
        int spy = s.projectionY(this,w);
        if ( (spx > 0) && (spy > 0) )
          return(true);
      }
      else
        return(true);
    }
    
    return(false);
  }
}

// Curve segment
class CrossSegment
{
  float ofsi;
  float ofsf;
  int cross;  // 0:No cross, 1:Cross preference, -1:Cross no preference
  
  CrossSegment(float oi, float of, int cr)
  {
    ofsi = oi;
    ofsf = of;
    cross = cr;
  }
}

// Curve data (managed as a polyline)
// It can be generated as a simple line or as a bezier curve
class Curve
{
  Point[] bz;   // Bezier curve control points
  Point[] bzp;  // Curve points
  float ln;    // Curve length
  int np;      // Curve points
  
  // Constructor for simple line and complex bezier curve
  Curve(Point p1, Point p2, Point p3, Point p4)
  {
    if ( (p3 != null) && (p4 != null) )  // $$$
      bezierCurve(p1,p2,p3,p4);
    else
      lineCurve(p1,p2);
  }
  
  void lineCurve(Point p1, Point p2)
  {
    np = 2;
    bzp = new Point[np];
    bzp[0] = new Point(p1.x, p1.y);
    bzp[1] = new Point(p2.x, p2.y);
      
    ln = dist(p1.x,p1.y,p2.x,p2.y);
  }
  
  void bezierCurve(Point p1, Point p2, Point p3, Point p4)
  {
    bz = new Point[2];
    bz[0] = new Point(p2.x,p2.y);
    bz[1] = new Point(p3.x,p3.y);
    
    // First, calculates approximate curve length using 50 reference points
    np = 50;
    ln = 0;
    float xi = 0;
    float yi = 0;
    float xf;
    float yf;
    for ( int i=0; i<np ; i++ )
    {
      float t = i / float(np-1);
      xf = bezierPoint(p1.x,p2.x,p3.x,p4.x, t);
      yf = bezierPoint(p1.y,p2.y,p3.y,p4.y, t);
      if ( i > 0 )
        ln += dist(xi,yi,xf,yf);
      xi = xf;
      yi = yf;
    }
    
    // Sets the optimum number of steps
    np = int(2*ln/Jslsz) + 1;
    bzp = new Point[np];
    for ( int i=0; i<np ; i++ )
    {
      float t = i / float(np-1);
      float x = bezierPoint(p1.x,p2.x,p3.x,p4.x, t);
      float y = bezierPoint(p1.y,p2.y,p3.y,p4.y, t);
      bzp[i] = new Point(x,y);
    }
  }
  
  // Returns a curve point by index
  Point getPoint(int i)
  {
    if ( i < np )
      return(bzp[i]);
    
    return(bzp[np-1]);
  }
  
  // Calculates curve length
  float len()
  {
    float l = 0;
    for ( int i=1; i<np ; i++ )
      l += dist(bzp[i].x,bzp[i].y,bzp[i-1].x,bzp[i-1].y);

    return(l);
  }

  // Obtains offset to the cross point between the curve and a segment
  // Returns crossing point or null if not crossing
  CrossPoint crossing(Segment s)
  {
    CrossPoint cp;
    Segment sbz = new Segment(bzp[0],bzp[1]);
    float ofs;
    
    ofs = 0;
    for ( int i=1 ; i<np ; i++ )
    {
      sbz.set(bzp[i-1],bzp[i]);
      cp = sbz.cross(s);
      if ( cp != null )
      {
        cp.ofs1 += ofs;
        return(cp);
      }
        
      ofs += dist(bzp[i-1].x,bzp[i-1].y,bzp[i].x,bzp[i].y);
    }
    
    return(null);
  }
  
  // Offset to a point near the curve (point at a distance less than r)
  // Returns -1 if no point is under r
  float offset(PVector p, float r)
  {
    PVector bip = new PVector(0,0);
    PVector bif = new PVector(0,0);
    float r2 = r*r;
    float sen2;
    float cos2;
    float cos;
    float bif2;
    float bifm;
    float ofs;
    
    ofs = 0;
    for ( int i=1 ; i<np ; i++ )
    {
      bif.set((bzp[i].x-bzp[i-1].x),(bzp[i].y-bzp[i-1].y),0);
      bifm = bif.mag();
      bif2 = bifm*bifm;
      bip.set((p.x-bzp[i-1].x),(p.y-bzp[i-1].y),0);
      sen2 = sq(bif.x*bip.y - bif.y*bip.x)/bif2;
      if ( sen2 <= r2 )
      {
        cos = (bif.x*bip.x + bif.y*bip.y)/bifm;
        if ( (cos > 0) && (cos < bifm) )
        {
          ofs += cos;
          return(ofs);
        }
        
        if ( (i > 1) && (cos < 0) )
        {
          if ( bip.mag() <= r )
            return(ofs);
        }
      }
      
      ofs += bifm;
    }
    
    return(-1);
  }
 
  // Obtains the curve section converging with another curve (dist < r)
  CrossSegment crossCurve(Curve c, float r)
  {
    float ofsi, ofsf;
    float ofs;
    float l;
    int cross;  // $$$
    boolean overlap;
    int imin;
    int jmin;
    
    ofs = 0;
    ofsi = -1;
    ofsf = -1;
    cross = 0;
    imin = 99999;
    jmin = 99999;
    Segment s = new Segment(bzp[0],bzp[1]);
    Segment g = new Segment(bzp[0],bzp[1]);
    for ( int i=1 ; i<np ; i++ )
    {
      // For all curve segments determines if they overlap with other curve segments
      s.set(bzp[i-1],bzp[i]);
      l = s.len();
      overlap = false;
      for ( int j=1 ; j<c.np ; j++ )
      {
        g.set(c.bzp[j-1],c.bzp[j]);
        if ( s.overlap(g,r) )
        {
          // Segments touching
          //println("Overlap: "+i+" : "+j);
          if ( ofsi < 0 )
          {
            // First segment overlapping
            ofsi = ofs;
            imin = i;
          }
          
          overlap = true;
          if ( j < jmin )
            jmin = j;
          ofsf = ofs + l;
          break;
        }
      }

      if ( (ofsi >= 0) && (overlap == false) )
        break;
      
      ofs += l;
    }

    if ( ofsi >= 0 )
    {
      // There is overlapping, returns overlapping segment
      if ( dist(bzp[0].x,bzp[0].y,c.bzp[0].x,c.bzp[0].y) > 1 )
      {
        // Crossing condition true (may fail in some extrange cases !!!)
        float sin = (bzp[imin].x-bzp[imin-1].x)*(c.bzp[jmin-1].y-bzp[imin-1].y) - (bzp[imin].y-bzp[imin-1].y)*(c.bzp[jmin-1].x-bzp[imin-1].x);
        if ( sin < 0 )
          cross = 1;
        else
          cross = -1;
      }
      else
        cross = 0;

      CrossSegment cs = new CrossSegment(ofsi,ofsf,cross);
      //println("OFSi: "+ofsi+" OFSf: "+ofsf);
      return(cs);
    }
    
    return(null);
  }
 
  // Displays curve
  void display()
  {
    pushStyle();
    noFill();
    stroke(120);
    if ( np > 2 )
      bezier(bzp[0].x,bzp[0].y,bz[0].x,bz[0].y,bz[1].x,bz[1].y,bzp[np-1].x,bzp[np-1].y);
    else
      line(bzp[0].x,bzp[0].y,bzp[1].x,bzp[1].y);
    
    // For debugging only
    //for ( int i=0; i<np ; i++ )
    //{
    //  ellipse(bzp[i].x,bzp[i].y,2,2);
    //}
    //
    popStyle();
  }

  // Displays line segment
  void displaySegment(float ofsi, float ofsf)
  {
    pushStyle();
    
    noFill();
    stroke(130);
    strokeWeight(12);
    if ( np == 2 )
    {
      PVector ps0 = new PVector((bzp[0].x-width/2),(bzp[0].y-height/2));
      float ps0m = ps0.mag();
      ps0.setMag(ps0m*Scale);
      ps0.add(width/2,height/2,0);
      PVector ps1 = new PVector((bzp[1].x-width/2),(bzp[1].y-height/2));
      float ps1m = ps1.mag();
      ps1.setMag(ps1m*Scale);
      ps1.add(width/2,height/2,0);
      line(ps0.x,ps0.y,ps1.x,ps1.y);
      if ( ofsi > ofsf )
      {
        PVector qv1 = new PVector((bzp[1].x-bzp[0].x),(bzp[1].y-bzp[0].y));
        PVector qv2 = qv1.get();
        qv1.setMag(ofsf*Scale);
        qv1.add(ps0.x,ps0.y,0);
        qv2.setMag(ofsi*Scale);
        qv2.add(ps0.x,ps0.y,0);
        stroke(255,0,0);
        line(qv1.x,qv1.y,qv2.x,qv2.y);
      }
      /*
      PVector qv1 = new PVector((bzp[1].x-bzp[0].x),(bzp[1].y-bzp[0].y));
      PVector qv2 = qv1.get();
      qv1.setMag(ofsf);
      qv1.add(bzp[0].x,bzp[0].y,0);
      qv2.setMag(ofsi);
      qv2.add(bzp[0].x,bzp[0].y,0);
      line(bzp[0].x,bzp[0].y,qv1.x,qv1.y);
      stroke(255,0,0);
      line(qv1.x,qv1.y,qv2.x,qv2.y);
      stroke(130);
      line(qv2.x,qv2.y,bzp[1].x,bzp[1].y);
      */
    }
    else
    {
      bezier(bzp[0].x,bzp[0].y,bz[0].x,bz[0].y,bz[1].x,bz[1].y,bzp[np-1].x,bzp[np-1].y);
    }
    
    // For debugging only
    //
    //for ( int i=0; i<np ; i++ )
    //  ellipse(bzp[i].x,bzp[i].y,2,2);
    //
    
    strokeWeight(1);
    popStyle();
  }
}

// Curve location data
class Location
{
  Curve cv;
  PVector coord;
  PVector dir;
  int cp;
  float ofs;
  float len;
  float accofs;
  boolean exit;
  
  Location(Curve c)
  {
    cv = c;
    cp = 0;
    ofs = 0;
    accofs = 0;
    dir = new PVector((c.bzp[1].x-c.bzp[0].x),(c.bzp[1].y-c.bzp[0].y),0);
    len = dir.mag();
    dir.normalize();
    coord = new PVector(c.bzp[0].x,c.bzp[0].y);
    exit = false;
  }
  
  // Init location data
  void init(Curve c)
  {
    cv = c;
    cp = 0;
    ofs = 0;
    accofs = 0;
    dir.set((c.bzp[1].x-c.bzp[0].x),(c.bzp[1].y-c.bzp[0].y),0); // $$$
    len = dir.mag();
    dir.normalize();
    coord.set(c.bzp[0].x,c.bzp[0].y,0);
  }
  
  // Updates location adding a step
  void update(float v)
  {
    exit = false;
    if ( ofs + v > len )
    {
      // Beyond the segment length
      if ( cp < cv.np - 2 )
      {
        // Move to next curve segment
        cp++;
        ofs += v - len;
        dir.set((cv.bzp[cp+1].x-cv.bzp[cp].x),(cv.bzp[cp+1].y-cv.bzp[cp].y),0);
        len = dir.mag();
        dir.normalize();
      }
      else
      {
        // Beyond the curve end point
        if ( cp < cv.np - 1 )
        {
          // In last segment
          cp++;
          ofs += v - len;
          len = 0;
        }
        else
          ofs += v;
          
        exit = true;
      }
    }
    else
    {
      // Inside current segment
      ofs += v;
    }

    // Update total accumulated offset and location coords
    accofs += v;
    coord.set(dir);
    coord.mult(ofs);
    coord.add(cv.bzp[cp].x,cv.bzp[cp].y,0);
  }
  
  // Location curve radius (0..1)
  float radius()
  {
    int np = cp + 10;
    if ( np > cv.np - 2 )
      np = cv.np - 2;
    if ( cp < np )
    {
      float ux = cv.bzp[cp+1].x - cv.bzp[cp].x;
      float uy = cv.bzp[cp+1].y - cv.bzp[cp].y;
      float u = ux*ux + uy*uy;
      float vx = cv.bzp[np+1].x - cv.bzp[np].x;
      float vy = cv.bzp[np+1].y - cv.bzp[np].y;
      float v = vx*vx + vy*vy;
      float sen = (ux*vy - uy*vx);
      float sen2 = sen*sen/(u*v);
      
      return(sen2);
    }
    
    return(0);
  }
}

// Crossing path data
class CrossPath
{
  Path pth;  // Crossing path
  CrossSegment cs;
  CrossSegment ps;
  boolean crossing;
  boolean preference;
  
  CrossPath(Path p, CrossSegment cs, CrossSegment ps)
  {
    pth = p;
    this.cs = cs;
    this.ps = ps;
    if ( cs.cross != 0 )
    {
      crossing = true;
      if ( cs.cross > 0 )
        preference = true;
      else
        preference = false;
    }
    else
    {
      crossing = false;
      preference = false;
    }
  }
  
  void display(Curve b)
  {
    float ofs;
    
    ofs = 0;
    pushStyle();
    strokeWeight(1);
    for ( int i=1 ; i<b.np ; i++ )
    {
      //if ( (ofs >= cs.ofsi) && (ofs <= cs.ofsf) && (crossing == true) )
      if ( (ofs >= cs.ofsi) && (ofs <= cs.ofsf) )
      {
        if ( cs.cross > 0 )
          stroke(0,200,0);
        else
          stroke(200,0,0);
        line(b.bzp[i-1].x,b.bzp[i-1].y,b.bzp[i].x,b.bzp[i].y);
      }
      
      ofs += dist(b.bzp[i-1].x,b.bzp[i-1].y,b.bzp[i].x,b.bzp[i].y);
    }
    popStyle();
  }
}

// Path loops related data (location offsets) 
class LoopData
{
  int s;  // Stop line
  int m;  // Movement
  float ofsi;
  float ofsf;
  boolean stat;  // On / Off
  
  LoopData(int sl, int tlm, float oi, float of)
  {
    s = sl;
    m = tlm;
    ofsi = oi;
    ofsf = of;
  }
  
  void set()
  {
    stat = true;
  }
  
  void reset()
  {
    stat = false;
  }
  
  void update(int i)
  {
    if ( stat )
      Sl[s].tlm[m].l.activate(i);
    else
      Sl[s].tlm[m].l.reset(i);
  }
}

// Blocking vehicle data
class Blkv
{
  float d;
  Vehicle v;
  
  Blkv(float d, Vehicle v)
  {
    this.d = d;
    this.v = v;
  }
}

// Vehicle class
class Vehicle
{
  int id;
  Path curp;   // Current path
  Path nxtp;   // Next linked path
  Location loc;  // Vehicle location
  float len;
  float wid;
  float maxspeed;
  float maxaccel;
  float maxdeccel;
  float freespeed;  // Free speed
  float speed;      // Current speed
  float dlimit;     // Distance limit to brake hard
  boolean braking;
  int reaction;     // Reaction time in milliseconds (-1:No reaction)
  boolean preference; // Preference after passing a traffic light (green/orange)
  Vehicle bv;    // Blocking vehicle
  int bvid;      // Id ahead vehicle, blocking vehicle or collision risk
  int bvtype;    // 0:Ahead, 1:Blocking, 2:Collision
  float bvdist;  // Blocking distance
  boolean blocked;
 
  Vehicle(Path cp)
  {
    id = NV++;
    curp = cp;
    nxtp = null;
    
    maxspeed = 1.5*1.4;
    freespeed = 1.5*(1 + 0.5*Rd.gauss());
    // println("Freespeed: "+freespeed);
    maxaccel = 0.007;
    maxdeccel = 0.027;
    dlimit = 25*(1 + 0.5*Rd.gauss());
    reaction = -1;
    braking = false;
    preference = true;
    
    loc = new Location(cp.b);
    speed = 0.5;  // !!!!
    wid = Jslsz/2;
    len = wid*2.2;
    
    bvid = -1;
    bvtype = 0;
    bv = null;
  }
 
  // Init path and location data
  void setPath(Path cp)
  {
    curp = cp;
    loc.init(cp.b);
  }
  
  // Adds location change tracking the defined curve
  void updateLocation(float v)
  {
    loc.update(v);
    
    // If leaving the path then assign traffic light status ???
  }    
  
  // Calculates desired speed based on the distance and speed of an obstacle
  // Uses a safe distance curve
  float desiredSpeed(float d, float so)
  {
    float desiredsp;
    float f;

    if ( so > freespeed )
      so = freespeed;
    if ( d > dlimit )
      f = 1 - 1/(1 + d/dlimit);
    else if ( d > dlimit/1.3 )
      f = 0.4;
    else if ( d > dlimit/2 )
      f = 0.07;
    else if ( d > dlimit/3.5 )
      f = 0.03;
    else
      f = 0;
    
    if ( d < 0.7*len )
      desiredsp = 0.95*so;
    else
      desiredsp = (freespeed - so)*f + so;

    return(desiredsp);
  }
  
  void setBlkv(int type, int id, Vehicle v, float d)
  {
    bvid = id;
    bvtype = type;
    bvdist = d;
    bv = v;
  }

  // Update vehicle location according to current situation and desired speed
  void update(float ds)
  {
    float accm;
    
    // Ideal acceleration considering desired speed
    accm = ds - speed;

    // Limits acceleration considering sign (accelerate or deccelerate)
    braking = false;
    if ( accm >= 0 )
    {
      //braking = false;
      if ( accm > maxaccel )
        accm = maxaccel;
    }
    else
    {
      //braking = true;
      if ( abs(accm) > maxdeccel )
      {
        //braking = true;
        accm = - maxdeccel;
      }
    }
    
    // Calculates new speed considering reaction time to acceleration changes
    float accln = 0;
    if ( ((speed < 0.01*freespeed) && (accm > 0)) || ((speed > 0.95*freespeed) && (accm == -maxdeccel)) )
    {
      if ( reaction > 0 )
      {
        // Reaction counter running
        if ( reaction < millis() )
        {
          //velocity.add(acc);
          accln = accm;
          reaction = -1;
        }
      }
      else
      {
        if ( speed < 0.05 )
          reaction = millis() + int((1300*Rd.gauss() + 100)/Simd.speed);
        else
          reaction = millis() + int((400*Rd.gauss() + 50)/Simd.speed);
      }
    }
    else
    {
      //velocity.add(acc);
      accln = accm;
    }

    speed += accln;
    if ( speed > maxspeed )
      speed = maxspeed;
       
    updateLocation(speed);  // $$$
  }
  
  // Checks if mouse over the vehicle
  boolean over(float xm, float ym)
  {
    if ( dist(xm,ym,loc.coord.x,loc.coord.y) < len/2 )
      return(true);
    
    return(false);
  }

  // Display vehicle (depending on mode birdeye)
  void display()
  {
    float theta = loc.dir.heading();
    int r = 4;
    
    pushStyle();
    strokeWeight(1);
    if ( braking == true )
      fill(200,0,0);
    else
      fill(200,200,30);
    stroke(0);

    // Draw the vehicle
    pushMatrix();
    translate(loc.coord.x,loc.coord.y);
    rotate(theta);
    if ( Mode3D )
      box(len,wid,4);
    else
      rect(-len/2,-wid/2,len,wid);
    
    if ( DebugMode )
    {
      fill(0,0,0,255);
      textSize(wid+2);
      text(str(id),2-len/2,0);
    }
    popMatrix();

    if ( DebugMode )
    {
      stroke(50);
      if ( (bv != null) && (bvtype > 0) )
        line(loc.coord.x,loc.coord.y,bv.loc.coord.x,bv.loc.coord.y);
      
      if ( (bv != null) && (bvtype > 0) )
      {
        switch ( int(bvtype) )
        {
          case 0:
            fill(0,200,0,255);  // Green ahead
            break;
          
          case 1:
            fill(200,0,0,255);  // Red blocking
            break;
            
          case 2:
            fill(0,100,250,255);  // Blue crossing
            break;
        }
        
        noStroke();
        rect(loc.coord.x,loc.coord.y-2*wid,1.5*len,wid+2);
        fill(0);
        textSize(wid+2);
        text(str(bvid),loc.coord.x,loc.coord.y-1.5*wid);
      }
    }

    popStyle();

    //rect(location.x-6,location.y-3,12,6);
  }
 
  // Run vehicle
  //  void run(Vehicle pv, Vehicle bv, float cd)
  void run(float ds)
  {
    update(ds);

    if ( BirdEye == false )
      display();
  }
}

// Path class
class Path
{
  int id;           // Path reference id (si,mi,sf,mf)
  Curve b;          // Path curve
  float split;      // Path splitting factor
  float maxsplit;   // Addition of splitting factors of the linked paths
  TrafficLight tl;  // Traffic light at path end
  ArrayList<Vehicle> vehicles; // Path vehicles
  ArrayList<Path> nxtp;        // Next paths linked to this path
  ArrayList<Path> prvp;        // Previous paths linked to this path
  ArrayList<CrossPath> crossp; // Crossing paths
  LoopData[] loops;            // Loops in this path
  int nloops;
  int lastloop;
  
  // Constructor for simple and complex bezier type path  $$$
  Path(int id, Point p1, Point p2, Point p3, Point p4, float split)
  {
    if ( (p3 != null) && (p4 != null) )
      bezierPath(id,p1,p2,p3,p4,split);
    else
      linePath(id,p1,p2,split);
  }
      
  // Constructor for a simple line path
  void linePath(int id, Point p1, Point p2, float split)
  {
    this.id = id;
    b = new Curve(p1,p2,null,null);
    this.split = split;
    //vs = new VehicleSystem(b);
    vehicles = new ArrayList<Vehicle>();
    tl = null;
    maxsplit = 0;
    nxtp = new ArrayList<Path>();
    prvp = new ArrayList<Path>();
    crossp = new ArrayList<CrossPath>();
    loops = null;
    lastloop = 0;
  }
  
  // Constructor for a complex bezier type path
  void bezierPath(int id, Point p1, Point p2, Point p3, Point p4, float split)
  {
    this.id = id;
    b = new Curve(p1,p2,p3,p4);
    this.split = split;
    // vs = new VehicleSystem(b);
    vehicles = new ArrayList<Vehicle>();
    tl = null;
    maxsplit = 0;
    nxtp = new ArrayList<Path>();
    prvp = new ArrayList<Path>();
    crossp = new ArrayList<CrossPath>();
    loops = null;
    lastloop = 0;
  }
  
  // Adds traffic light to the path end
  void addTL(int ref)
  {
    tl = new TrafficLight(b,ref);
  }
  
  // Adds loops (constants used in loop !!!)
  void addLoops(int sl, int tlm, int nl, float sz)
  {
    if ( nl > 0 )
    {
      loops = new LoopData[nl];
      nloops = nl;
      float ofs = b.ln - 3*sz;
      for ( int i=0 ; i<nl ; i++ )
      {
        loops[i] = new LoopData(sl,tlm,ofs-sz/2,ofs+sz/2);
        ofs -= (sz + 6);
      }
    }
  }
  
  // Reset loops status
  void resetLoops()
  {
    for ( int i=0 ; i<nloops ; i++ )
      loops[i].reset();
  }

  // Checks if vehicle over a loop
  void checkLoops(Vehicle v)
  {
    for ( int i=0 ; i<nloops ; i++ )
    {
      if ( (v.loc.accofs+v.len/2 >= loops[i].ofsi) && (v.loc.accofs-v.len/2 < loops[i].ofsf) )
        loops[i].set();
    }
  }
  
  // Updates loops status
  void updateLoops()
  {
    for ( int i=0 ; i<nloops ; i++ )
      loops[i].update(i);
  }
  
  // Links a path to this path
  void link(Path pth)
  {
    pth.prvp.add(this);
    nxtp.add(pth);
    maxsplit += pth.split;
  }

  // Checks if a path is a linked path
  boolean isLinkedNxt(Path p)
  {
    for ( Path lp: nxtp )
      if ( lp == p )
        return(true);
    
    return(false);
  }
  
  // Checks if this path is linked to other path
  boolean isLinkedPrv(Path p)
  {
    for ( Path lp: prvp )
      if ( lp == p )
        return(true);
    
    return(false);
  }
  
  // Checks if a given path crosses this path
  // Returns the crosspath data or null
  CrossSegment checkCrossPath(Path p)
  {
    CrossSegment cs;

    if ( isLinkedNxt(p) || isLinkedPrv(p) )
      return(null);
      
    cs = b.crossCurve(p.b,Jslsz/1);  // div 1.5 ?
    
    return(cs);
  }

  // Adds cross path data to the CrossPath list
  void addCrossPath(CrossSegment cs, Path p)
  {
    CrossSegment ps = p.b.crossCurve(this.b,Jslsz/1);
    CrossPath ncp = new CrossPath(p,cs,ps);
    for ( int i=0 ; i<crossp.size() ; i++ )
    {
      CrossPath cpth = crossp.get(i);
      if ( cs.ofsi < cpth.cs.ofsi )
      {
        //println("Add CrossPath to "+hex(id)+" => ofsi: "+cs.ofsi+" , ofsf: "+cs.ofsf);
        crossp.add(i,ncp);
        return;
      }
    }
    
    //println("Add CrossPath to "+hex(id)+" => ofsi: "+cs.ofsi+" , ofsf: "+cs.ofsf);
    crossp.add(crossp.size(),ncp);
  }
  
  // Determines next path to follow according to the splitting factor (weighted random)
  Path nextPath()
  {
    float r = random(int(1000*maxsplit));
    r /= 1000;
    float s = 0;
    for ( Path p: nxtp )
    {
      s += p.split;
      if ( r < s )
        return(p);
    }

    return(null);
  }
  
  // Determines if the path has room for a new vehicle at entry point
  float pathRoom()
  {
    int n;
    
    if ( (n=vehicles.size()) > 0 )
    {
      // There are vehicles in the path
      Vehicle lv = vehicles.get(n-1);  // Last vehicle added
      // println("Room NV: "+n+" Ofs: "+lv.accofs);
      return(lv.loc.accofs);
    }
    
    // Max. room
    return(200);
  }
  
  // Checks for vehicles in range of collision in a crossing path
  // Returns the first vehicle found or null
  Vehicle vehicleInRange(float t1, float d1, float ofsi)
  {
    Path pth = this;
    float accofs = 0;
    while ( pth != null )
    {
      for ( int i=0 ; i<vehicles.size() ; i++ )
      {
        // Searches list from the last one to the first one in the path
        Vehicle v = vehicles.get(i);
        float d2 = ofsi + accofs - v.loc.accofs;
        if ( t1 > 0 )
        {
          if ( (d2 - 100 < v.speed*t1) && (d2 + 40 > v.speed*t1) )
          {
            // In range
            return(v);
          }
        }

        if ( (d1 < 60) && (d1 > -20) && (d2 < 50) && (d2 > -20) )
        {
          // In range
          return(v);
        }
        
      }
      
      // Check in previous paths if necessary
      //
      //if ( maxofs - accofs < distance )
      //{
        //pth = pth.prvp;  // Puede haber varios !!!!
        //if ( pth != null )
        //  accofs += pth.b.ln;
      //}
      //
      pth = null;   
    }

    return(null);
  }
  
  // Checks possible collision risk in next crossing points up to a distance
  // Returns desired speed to avoid collision
  Blkv crossingVehicle(Vehicle v, float maxd)
  {
    float ti, tf;
    
    
    //v.braking = false;  // !!!
    Path pth = this;
    float accofs = 0;
    float vofs = v.loc.accofs;
    while ( pth != null )
    {
      for ( CrossPath c: pth.crossp )
      {
        if ( c.crossing == true )
        {
          // Crossing path, calculate distance to crossing point
          float d = c.cs.ofsi + accofs - vofs;
          if ( (d > -20) && (d < maxd) )
          {
            if ( d > 0 )
            {
              // Time to reach crossing
              if ( v.speed < 0.1*v.freespeed )
              {
                //if ( d > 30 )
                  //return(null);
              
                ti = sqrt(2*d/v.maxaccel);
              }
              else
              {
                ti = d / v.speed;
              }
            }
            else
            {
              // Already in crossing area
              ti = 0;
            }
              
            // Check from crossing vehicle in risky distance        
            Vehicle cv = c.pth.vehicleInRange(ti,d,c.ps.ofsi);
            if ( cv != null )
            {
              // Collision risk
              // v.braking = true;  // !!!
              //println("Preference: "+v.preference+" tcf: "+tcf);
              //println("TGap*Speed: "+(tgap*v.speed));
              if ( ((v.preference == cv.preference) && (c.preference == false)) ||
                   ((v.preference != cv.preference) && (v.preference == false)) )
              {
                // No preference, returns blocking data
                if ( cv.blocked )
                {
                  // Vehicle has not preference but it is blocking so move ahead
                  // println("Vehículo bloqueado");
                  return(null);
                }
                
                if ( d < 0 )
                  d = 0;
                  
                return(new Blkv(d,cv));
              }
              
              // Preference but risk...
              return(null);
            }
          }
        }
      }
      
      // Check int next path if necessary
      accofs += pth.b.ln;  // End of current path
      if ( accofs - vofs < maxd )
        pth = v.nxtp;
      else
        pth = null;
    }
    
    // No risk, continue (at freespeed ?)
    return(null);
  }
  
  // Search for blocking vehicle ahead of the given one in nearby paths
  // Returns desired speed to avoid collision
  Blkv blockingVehicle(Vehicle v, float maxd)
  {
    Vehicle pv;
    Vehicle bv;
    int n;
    float ofsv;
    float d;

    float rest = 0;
    float ofsmax = v.loc.accofs + maxd + v.len/2;
    if ( ofsmax > b.ln )
    {
      rest = ofsmax - b.ln;
      ofsmax = b.ln;
    }
    
    d = 0;
    bv = null;
    v.blocked = false;
    // First cross paths in this path
    for ( CrossPath cpth: crossp )
    {
      if ( (ofsmax > cpth.cs.ofsi) && (v.loc.accofs - v.len/2 < cpth.cs.ofsf) )
      {
        n = cpth.pth.vehicles.size();
        for ( int i=0 ; i<n ; i++ )
        {
          // Check vehicles in the cross path (the closest)
          pv = cpth.pth.vehicles.get(i);
          if ( (pv.loc.accofs + pv.len/2 >= cpth.ps.ofsi) && (pv.loc.accofs - pv.len/2 <= cpth.ps.ofsf) )
          {
            ofsv = b.offset(pv.loc.coord,Jslsz/2);
            //ofsv = (pv.loc.accofs - cpth.ps.ofsi) + cpth.cs.ofsi;
            if ( (ofsv > v.loc.accofs) && (ofsv < ofsmax) )
            {
              bv = pv;
              ofsmax = ofsv;
              d = ofsv - v.loc.accofs - v.len;
              if ( d < 0 )
                d = 0;
              //break;
            }
          }
        }
      }
    }
            
    if ( bv != null )
    {
      if ( d < 2*v.len)
        v.blocked = true;
        
      return(new Blkv(d,bv));
    }

    // If no blocking vehicle in this path then check someone in next path
    if ( (rest > 0) && (v.nxtp != null) )
    {
      ofsmax = rest;
      for ( CrossPath cpth: v.nxtp.crossp )
      {
        if ( cpth.cs.ofsi < rest )
        {
          n = cpth.pth.vehicles.size();
          for ( int i=0 ; i<n ; i++ )
          {
            pv = cpth.pth.vehicles.get(i);
            if ( (pv.loc.accofs + pv.len/2 >= cpth.ps.ofsi) && (pv.loc.accofs - pv.len/2 <= cpth.ps.ofsf) )
            {
              ofsv = v.nxtp.b.offset(pv.loc.coord,Jslsz/2);
              //ofsv = (pv.loc.accofs - cpth.ps.ofsi) + cpth.cs.ofsi;
              if ( (ofsv > 0) && (ofsv < ofsmax) )
              {
                bv = pv;
                ofsmax = ofsv;
                d = b.ln - v.loc.accofs - v.len/2 + ofsv;
                //break;
              }
            }
          }
        }
      }
              
      if ( bv != null )
      {
        if ( d < 2*v.len)
          v.blocked = true;
          
        return(new Blkv(d,bv));
      }
    }

    return(null);
  }
  
  // Next ahead vehicle in the given path
  // Returns desired speed to avoid collision
  Vehicle aheadVehicle(Path p)
  {
    if ( p != null )
    {
      int nv = p.vehicles.size();
      if ( nv > 0 )
      {
        Vehicle av = p.vehicles.get(nv-1);
        return(av);
      }
    }
    
    return(null);
  }
 
  // Displays path curve and associated traffic lights
  void display()
  {
    //b.display();
    if ( tl != null )
      tl.display();
    
    // Displays crossing points for debugging
    
    if ( DebugMode )
    {
      for ( CrossPath cp: crossp )
        cp.display(b);
    }
    
  }
  
  // Calculates queue start point (first vehicle stopped)
  float queueStart()
  {
    for ( int i=0 ; i<vehicles.size() ; i++ )
    {
      // Searches list from the last one to the first one in the path
      Vehicle v = vehicles.get(i);
      float vofs = v.loc.accofs;
      if ( v.speed < 0.1*v.freespeed )  // 0.1!!!
        return(vofs);
    }
    
    return(0);
  }
  
  // Calculates queue end point (last vehicle stopped)
  float queueEnd(float sofs)
  {
    if ( sofs == 0 )
      return(0);
      
    float ofs = b.ln;
    for ( int i=0 ; i<vehicles.size() ; i++ )
    {
      // Searches list from the last one to the first one in the path
      Vehicle v = vehicles.get(i);
      float vofs = v.loc.accofs;
      if ( (v.speed > 0.1*v.freespeed) && (vofs < sofs) )  // !!!
        return(ofs);
      
      ofs = vofs;
    }
    
    return(ofs);
  }
  
  // Displays bird eye path and associated traffic lights
  void displayBE()
  {
    if ( b.np == 2 )
    {
      float ofsi = queueStart();
      float ofsf = queueEnd(ofsi);

      b.displaySegment(ofsi,ofsf);
    }
    
    if ( tl != null )
      tl.display();
  }
  
  // Add a new vehicle to the path
  void addVehicle(Vehicle v)
  {
    v.setPath(this);
    // Asigns next path
    if ( maxsplit > 0 )
      v.nxtp = nextPath();
    else
      v.nxtp = null;

    vehicles.add(v);
  }

  // Init vehicles in the access lane path
  void initVehicles(int f)
  {
    float gap;
    float d = b.ln;
    
    // fills the access path with vehicles according to the estimated density
    d -= 120*(1 + 0.3*Rd.gauss());
    while ( d > 0 )
    {
      Vehicle v = new Vehicle(this);
      addVehicle(v);
      v.speed = v.freespeed;
      v.updateLocation(d);
      gap = 30*v.speed*(1 + 0.8*Rd.gauss())*3600/f;  // !!!
      if ( gap < v.len )
        gap = 1.5*v.len;
      d -= gap;
    }
  }
  
  // Runs path vehicle system
  void run(int loopid)
  {
    Blkv bv;
    Vehicle av = null;
    Vehicle v;
    float desiredsp;
    float ds;
    float da;
    
    // Avoid more than one run call by iteration
    if ( loopid == lastloop )
      return;
    
    lastloop = loopid;
    
    //Reset loops status
    resetLoops();
    
    int nv = vehicles.size();
    if ( nv > 0 )
    {
      for ( int i=0 ; i<nv ; i++ )
      {
        v = vehicles.get(i);

        // Default desired speed depending on path curvature
        desiredsp = v.freespeed*(1 - v.loc.radius()/2);
        da = 130;
        
        // Init blocking vehicle data
        v.setBlkv(0,0,null,0);
        
        if ( i == 0 )
        {
          // Checks red light ahead for first vehicle in path
          if ( tl != null )
          {
            if ( tl.type == 0 )
            {
              da = tl.ofs - v.loc.accofs;
              ds = v.desiredSpeed(da,0);
              if ( ds < desiredsp )
                desiredsp = ds;
            }
          }
          // Checks ahead vehicle (in next path) !!! max da
          av = aheadVehicle(v.nxtp);
          if ( av != null )
          {
            da = b.ln - v.loc.accofs + av.loc.accofs - v.len;  // !!!
            if ( da < 0 )
              da = 0;
            ds = v.desiredSpeed(da,av.speed);
          }
          else
            ds = desiredsp;
        }
        else
        {
          // Next vehicle
          da = av.loc.accofs - v.loc.accofs - v.len;  // !!!
          if ( da < 0 )
            da = 0;
          ds = v.desiredSpeed(da,av.speed);
        }
        
        if ( av != null )
        {
          if ( ds < desiredsp )
          {
            desiredsp = ds;
            v.setBlkv(0,av.id,av,da);
          }
        }
        if ( da > 100 )
          da = 100;
        
        // Checks blocking vehicle
        bv = blockingVehicle(v,da+30);
        if ( bv != null )
        {
          float sp = bv.v.speed*v.loc.dir.dot(bv.v.loc.dir);
          if ( sp < 0 )
            sp = 0;
          ds = v.desiredSpeed(bv.d,sp);
          if ( ds < desiredsp )
          {
            v.setBlkv(1,bv.v.id,bv.v,bv.d);
            if ( (v.blocked) && (v.speed == 0) && (v.bv.blocked) && (v.bv.speed == 0) )
            {
              // Interblocked, go ahead slowly if preference
              if ( v.preference )
              {
                desiredsp = 0.2*v.freespeed;
                v.speed = 0.01;  // To avoid delay
                println("Unblocked");
              }
              else
                desiredsp = ds;
            }
            else
              desiredsp = ds;
          }
        }
        
        // Checks collision risk with crossing paths up to the given distance
        bv = crossingVehicle(v,da+30);
        if ( bv != null )
        {
          ds = v.desiredSpeed(bv.d,0);
          if ( ds < desiredsp )
          {
            desiredsp = ds;
            v.setBlkv(2,bv.v.id,bv.v,bv.d);
          }
        }

        // Checks over loops
        checkLoops(v);
        
        v.run(desiredsp);
        av = v;
      }
      
      // Now, remove vehicles leaving the path
      v = vehicles.get(0);  // Most ahead vehicle 
      if ( v.loc.exit == true )
      {
        // Vehicle beyond the path end point
        if ( v.nxtp != null )
        {
          // Move vehicle to next path
          float ofs = v.loc.ofs;
          v.nxtp.addVehicle(v);
          v.updateLocation(ofs);
          // If traffic light in leaving path then assign preference
          if ( tl != null )
          {
            if ( tl.type == 1 )
              v.preference = true;
            else
              v.preference = false;
          }
        }
        
        // Remove vehicle from the current path
        vehicles.remove(0);
      }
    }
    
    // Updates path loops status
    updateLoops();
  }
}

// Access lane class
// It consist of a single line path up to the stop line
// Access lane path will be linked to several paths at the stop line point
class AccessLane
{
  Path lanep;  // Lane access path
  int q;         // Vehicles queue for this lane
  int intensity; // Lane v/h
  int period;    // Average milliseconds between vehicles
  int msec;      // Millisecond to add a new vehicle to the lane
  int extractdelay;  // Milliseconds to extract a vehicle from the lane
  Point org;
  float phi;
  
  AccessLane(Point p1, Point p2, int intens)
  {
    lanep = new Path(0,p1,p2,null,null,1);
    org = new Point(p1.x,p1.y);
    PVector v = new PVector(p2.x-p1.x,p2.y-p1.y);
    phi = v.heading();
    intensity = intens;
    q = 0;

    if ( intens > 0 )
    {
      period = round(3600000/intens);
      msec = millis() + int(period*(1 + 0.8*Rd.gauss()));
    }
    
    extractdelay = 0;
  }
/*  
  // Links a new path to the lane path (giving 2 or 3 bezier vector points) $$$
  Path addPath(Point p2, Point p3, Point p4, float split)
  {
    if ( p2 != null )
      return(addPath3(p2,p3,p4,split));

    return(addPath2(p3,p4,split));
  }

  // Links a new path to the lane path (giving bezier vector for end point)
  Path addPath2(Point p3, Point p4, float split)
  {
    PVector p = new PVector(p4.x-p3.x,p4.y-p3.y);
    float m = p.mag();
    Point p0 = lanep.b.bzp[0];
    Point p1 = lanep.b.bzp[1];
    PVector q = new PVector(p1.x-p0.x,p1.y-p0.y);
    q.setMag(m);
    q.add(p1.x,p1.y,0);
    Point p2 = new Point(q.x,q.y);
    Path pth = new Path(0,p1,p2,p3,p4,split);

    lanep.link(pth);
    
    return(pth);
  }
  
  // Links a new path to the lane path (giving 3 bezier points)
  Path addPath3(Point p2, Point p3, Point p4, float split)
  {
    Point p1 = lanep.b.bzp[1];
    Path pth = new Path(0,p1,p2,p3,p4,split);

    lanep.link(pth);
    
    return(pth);
  }
*/  
  // Adds traffic light at the lane path end
  void addTL(int ref)
  {
    lanep.addTL(ref);
  }
  
  // Adds loops to the lane path
  void addLoops(int sl, int tlm, int nl, float sz)
  {
    lanep.addLoops(sl,tlm,nl,sz);
  }
  
  // Init vehicles in the access lane path
  void initVehicles()
  {
    lanep.initVehicles(intensity);
  }
  
  // Display access lane queue and paths
  void display()
  {
    if ( BirdEye == false )
    {
      /* !!!
      int sz = 40;
      stroke(255);
      strokeWeight(1);  // $$$
      int f = q;
      if ( f > sz )
        f = sz;
      int r = round(255*f/sz);
      int g = 255 - r;
 
      pushMatrix();
      translate(org.x,org.y);
      rotate(phi);
      fill(0);
      rect(-sz-10,-4,sz,8);
      fill(r,g,0);
      rect(-f-10,-4,f,8);
      popMatrix();
      */
      
      lanep.display();
      for ( Path p: lanep.nxtp )
      {
        p.display();
        for ( Path p2: p.nxtp )
        {
          p2.display();
          for ( Path p3: p2.nxtp )
          {
            p3.display();
          }
        }
      }
    }
    else
    {
      lanep.displayBE();
    }
  }
  
  // Lane run loop
  void run(int loopid)
  {
    // Add a vehicle to the queue every P miliseconds
    // Applies random gaussian period
    int m = millis();
    if ( (intensity > 0) && (m > msec) )
    {
      q++;
      msec = m + int(period*(1 + 0.8*Rd.gauss())/Simd.speed);
    }
    
    // Extracts a vehicle from the queue if there is room in the lane path
    if ( q > 0 )
    {
      if ( extractdelay < m )
      {
        float room = lanep.pathRoom();
        if ( room > 30 )
        {
          Vehicle nv = new Vehicle(lanep);
          nv.speed = 0.5*nv.freespeed;  // Depende de la velocidad del anterior !!!
          lanep.addVehicle(nv);
          q--;
          extractdelay = m + int((1000*(1 + 0.8*Rd.gauss()))/Simd.speed);
        }
      }
    }      

    // Run paths (up to 3 levels)
    lanep.run(loopid);
    for ( Path p: lanep.nxtp )
    {
      p.run(loopid);
      for ( Path p2: p.nxtp )
      {
        p2.run(loopid);
        for ( Path p3: p2.nxtp )
          p3.run(loopid);
      }
    }
      
  }
}

// Access class, handles the access lanes at an access point
class Access
{
  ArrayList<AccessLane> lanes;
  
  Access()
  {
    lanes = new ArrayList<AccessLane>();
  }
  
  AccessLane addLane(Point p1, Point p2, int i)
  {
    AccessLane l = new AccessLane(p1,p2,i);
    lanes.add(l);
    
    return(l);
  }
  
  // Display access status
  void display()
  {
    for ( AccessLane l: lanes )
      l.display();
  }
  
  // Access loop
  void run(int count, int loopid)
  {
    for ( AccessLane l: lanes )
    {
      if ( count == 1 )
        l.display();
        
      l.run(loopid);
    }
  }
}


// Junction system class
class JSystem
{
  ArrayList<Access> access;
  boolean init;
  int lastph;
  int loopid;
  
  JSystem()
  {
    access = new ArrayList<Access>();
    init = false;
    lastph = -1;
    loopid = 0;
  }
  
  Access addAccess(Access acc)
  {
    access.add(acc);
    
    return(acc);
  }
  
  // Updates path crossings with other paths (near paths)
  void updateCrossings(Path p1)
  {
    CrossSegment cs;
    
    for ( Access a: access )
    {
      for ( AccessLane l: a.lanes )
      {
        // Checks paths starting at access lanes
        for ( Path p2: l.lanep.nxtp )
        {
          if ( p1 != p2 )
          {
            cs = p1.checkCrossPath(p2);
            if ( cs != null )
            {
              //println("Add Cross Path (1): "+p1+" = "+p2+" OFS: "+cs.ofsi);
              p1.addCrossPath(cs,p2);
            }
          }

          // Now checks paths linked to access lanes paths
          for ( Path p3: p2.nxtp )
          {
            if ( p1 != p3 )
            {
              cs = p1.checkCrossPath(p3);
              if ( cs != null )
              {
                //println("Add Cross Path (2): "+p1+" = "+p3+" OFS: "+cs.ofsi);
                p1.addCrossPath(cs,p3);
              }
            }
          }
        }
      }
    }
  }
  
  // Initializes JSystem data
  void initialize()
  {
    for ( Access a: access )
    {
      for ( AccessLane l: a.lanes )
      {
        l.initVehicles();
        for ( Path p: l.lanep.nxtp )
        {
          updateCrossings(p);
          for ( Path p2: p.nxtp )
            updateCrossings(p2);
        }
      }
    }
  }
  
  // Check if path exist
  Path hasPath(int pid)
  {
    for ( Access a: access )
    {
      for ( AccessLane l: a.lanes )
      {
        for ( Path p: l.lanep.nxtp )
        {
          if ( p.id == pid )
            return(p);
            
          for ( Path p2: p.nxtp )
          {
            if ( p2.id == pid )
              return(p2);
            
            for ( Path p3: p2.nxtp )
            {
              if ( p3.id == pid )
                return(p3);
            }
          }
        }
      }
    }
    
    return(null);
  }
  
  // Checks if coords over a vehicle (debug)
  Vehicle overVehicle(float xm, float ym)
  {
    for ( Access a: access )
    {
      for ( AccessLane l: a.lanes )
      {
        for ( Path p: l.lanep.nxtp )
        {
          for ( Vehicle v: p.vehicles )
            if ( v.over(xm,ym) )
              return(v);
            
          for ( Path p2: p.nxtp )
          {
            for ( Vehicle v: p.vehicles )
              if ( v.over(xm,ym) )
                return(v);
            
            for ( Path p3: p2.nxtp )
            {
              for ( Vehicle v: p.vehicles )
                if ( v.over(xm,ym) )
                  return(v);
            }
          }
        }
      }
    }
    
    return(null);
  }

  // Display junction system
  void display()
  {
    for ( Access a: access )
      a.display();
  }
  
  // Junction system loop
  void run(JStruct Js)
  {
    if ( init == false )
    {
      init = true;
      initialize();
    }
    
    int ph = Js.sel;
    if ( ph != lastph )
    {
      UpdateTrafficLights(Js.Ph[ph]);
      lastph = ph;
    }
    
    int count = Simd.speed;
    while ( count > 0 )
    {
      loopid++;
      for ( Access a: access )
      {
        //a.display();
        a.run(count,loopid);
      }
      
      count--;
    }
  }
}

// Traffic light class
class TrafficLight
{
  int type;  // 0:red, 1:green, 2:orange
  float ofs;
  PVector location;
  int ref;
  
  TrafficLight(Curve c, int r)
  {
    location = new PVector(c.bzp[c.np-1].x,c.bzp[c.np-1].y);
    ofs = c.len();
    type = 0;
    ref = r;
  }
  
  void set(int t)
  {
    type = t;
  }
  
  void display()
  {
    /*
    if ( green == true )
    {
      stroke(0,255,80);
      fill(0,255,80);
    }
    else
    {
      stroke(255,0,0);
      fill(255,0,0);
    }
    ellipse(location.x,location.y,8,8);
    */
  }
}


// Create new path
Path CreatePath(Movement mv, StopLine[] sl)
{
  Path pt;
  float xi, yi;
  float xr, yr;
  float xf, yf;
  float xs, ys;
  int si = mv.si;
  int mi = mv.mi;
  int sf = mv.sf;
  int mf = mv.mf;
  
  int pid = (si << 24) | (mi << 16) | (sf << 8) | mf;
  pt = JSys.hasPath(pid);
  if ( pt != null )
    return(pt);
  
  println("Path: "+si+","+mi+" -> "+sf+","+mf);
  if ( mf < 3 )
  {
    xi = sl[si].tlm[mi].x;  // xo
    yi = sl[si].tlm[mi].y;
    xr = xi + mv.cpi.x;
    yr = yi + mv.cpi.y;
  
    xf = sl[sf].tlm[mf].x;
    yf = sl[sf].tlm[mf].y;
    xs = xf + mv.cpf.x;
    ys = yf + mv.cpf.y;
  
    println("Add path: -> "+xf+" , "+yf);
    pt = new Path(pid,new Point(xi,yi), new Point(xr,yr),new Point(xs,ys),new Point(xf,yf),1);
  }
  else
  {
    // Exit path
    xi = sl[si].tlm[mi].x;  // xo
    yi = sl[si].tlm[mi].y;
    xf = sl[sf].acp[mf-3].x;
    yf = sl[sf].acp[mf-3].y;
  
    println("Add path: -> "+xf+" , "+yf);
    pt = new Path(pid,new Point(xi,yi), new Point(xf,yf),null,null,1);
  }
  
  return(pt);
}

void InitSimulator(int nsl, StopLine[] sl, int nmv, Movement[] mv, float lsz)
{
  float xi, yi, xf, yf;
  float xr, yr, xs, ys;
  float di, df, ext;
  float vx, vy;
  int f, mf;
  int g, mg;
  
  // Junction structure
  JSys = new JSystem();
  Jslsz = lsz; // !!!

  // First creates access lanes and linked paths 
  for ( int i=0 ; i<nsl ; i++ )
  {
    if ( sl[i].del == false )
    {
      if ( sl[i].type == 1 )
      {
        // Creates entry access lanes (for each traffic light movement)
        Access acc = new Access();
        for ( int j=0 ; j<sl[i].nm ; j++ )
        {
          xf = sl[i].tlm[j].x;
          yf = sl[i].tlm[j].y;
          float sz = sl[i].tlm[j].sz;
          xi = xf + 50*sz*sl[i].uy;  // 5
          yi = yf - 50*sz*sl[i].ux;
          AccessLane ln = acc.addLane(new Point(xi,yi),new Point(xf,yf),1500); // !!!
          println("Add lane: -> "+xf+" , "+yf);
          // Adds traffic light to the access lane
          ln.addTL(MRef(i,j));
          // Adds loops to the access lane
          int nl = sl[i].tlm[j].l.nl;
          ln.addLoops(i,j,nl,sz);
          // Adds linked paths to access lanes
          for ( int k=0 ; k<nmv ; k++ )
          {
            if ( (mv[k].del == false) && (mv[k].si == i) && (mv[k].mi == j) )
            {
              f = mv[k].sf;
              mf = mv[k].mf;
              // Adds linked paths
              Path p1 = CreatePath(mv[k],sl);
              ln.lanep.link(p1);
              // Adds traffic light to the path
              p1.addTL(MRef(f,mf));
              
              // If path ends at an intermediate stop line then link the new paths
              if ( sl[f].type == 3 )
              {
                for ( int n=0 ; n<sl[f].nm ; n++ )
                {
                  for ( int m=0 ; m<nmv ; m++ )
                  {
                    if ( (mv[m].del == false) && (mv[m].si == f) && (mv[m].mi == n) )
                    {
                      g = mv[m].sf;
                      mg = mv[m].mf;
                      // Adds linked paths
                      Path p2 = CreatePath(mv[m],sl);
                      p1.link(p2);
                      // Adds traffic light to the path
                      p2.addTL(MRef(g,mg));
                      
                      // Exit paths
                      for ( int s=0 ; s<sl[g].nm ; s++ )
                      {
                        for ( int t=0 ; t<nmv ; t++ )
                        {
                          if ( (mv[t].del == false) && (mv[t].si == g) && (mv[t].mi == s) )
                          {
                            // Adds linked paths
                            Path p3 = CreatePath(mv[t],sl);
                            p2.link(p3);
                          }
                        }
                      }
                    }
                  }
                }
              }
              else
              {
                // Exit paths
                for ( int n=0 ; n<sl[f].nm ; n++ )
                {
                  for ( int m=0 ; m<nmv ; m++ )
                  {
                    if ( (mv[m].del == false) && (mv[m].si == f) && (mv[m].mi == n) )
                    {
                      // Adds linked paths
                      Path p2 = CreatePath(mv[m],sl);
                      p1.link(p2);
                    }
                  }
                }
              }
            }
          }
        }
        
        // Adds new access structure
        JSys.addAccess(acc);
      }
    }
  }
}

// 
void SetTrafficLight(Phase ph, Path p)
{
  int type;
  
  if ( p.tl != null )
  {
    int rm = p.tl.ref;
    int im = ph.hasMovRef(rm);
    if ( im >= 0 )
      type = ph.movType(im);
    else
      type = 0;
  
    p.tl.set(type);
  }
}

// Update traffic lights according the selected phase
void UpdateTrafficLights(Phase ph)
{
  for ( Access a: JSys.access )
  {
    // First, traffic lights at access lanes
    for ( AccessLane l: a.lanes )
    {
      SetTrafficLight(ph,l.lanep);
      // Second, traffic lights at first level linked paths
      for ( Path p: l.lanep.nxtp )
      {
        SetTrafficLight(ph,p);
        // Finally, for all paths linked to the these
        for ( Path p2: p.nxtp )
        {
          SetTrafficLight(ph,p2);
        }
      }
    }
  }
}


