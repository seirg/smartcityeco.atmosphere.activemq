/*
  @pjs globalKeyEvents="true";
*/
// Junction View Editor
// Carlos Gil 10/2013 - 3/2014 

//String FileName = "junction2";
/*JSVar:*/ FileName;

String PathData = "SmartJE/data/";
//String PathData = "data/";


String SampleFileName = "junction";
int Jid = 1;


boolean Enable3D = false;      // 3D must be disabled for HTML5
boolean ContinuousLoop = true;  // Required to run 3D in some computers

// Program constants
int LEFT_MOV = 1;
int FRONT_MOV = 2;
int RIGHT_MOV = 4;

// Global vars
boolean BirdEye = false;  // Bird eye mode
int HeaderH = 20;  // Header bar heigth
int FooterH = 20;  // Foot bar height
int Mode = 0;      // 0:Edit stop lines, 1:Edit movements, 2:Test mode
Boolean Changes = false;  // Changes not saved
PGraphics pg;  // Junction geometry
boolean Mode3D  = false;
boolean CPULimit = false;  // True when unable to run the loop at 60 Hz
String Helps = "";  // Context help string $$$
String Warns = "";  // Warning string
int Warnt = 0;
float FRate = 60;

PImage Bkimg = null;  // Background image for layout reference
PShape Bkshp = null;
int BackMode = 3;  // 0:None, 1:Rendered, 2:Sat, 3:Mask&Sat, 4:Mask
float Scale = 1;
boolean Simulation = false;
boolean Paused = true;

MenuBar MainMenu;
MenuBar Menu0;  // Menu for Mode 0
MenuBar Menu1;  // Menu for Mode 1
MenuBar Menu20;  // Menu for Mode 2
MenuBar Menu21;  // Menu for Mode 2 in simulation


// Array of stop lines
int Maxsl = 50;
int Nsl = 0;
StopLine[] Sl = new StopLine[Maxsl];
int SelSl = -1;  // Stop Line selected
int Maxln = 10;  // Max. number of lanes
float Lsz = 0;   // Default lane size (initially undefined)

// Array of movements
int Maxmv = 100;
int Nmv = 0;
Movement[] Mv = new Movement[Maxmv];
int SelMv = -1;  // Movement line selected
int DrgMv = -1;  // Movement line dragged


// Junction phases and timing structure
JStruct JS;


void contextHelp(String s)
{
  if ( s == null )
    return;
   
  if ( s.equals(Helps) == false )
  {
    Helps = s;
    redraw();
  }
}

void Warning(String s, int sec)
{
  if ( s == null )
    return;

  Warns = s;
  Warnt = millis() + 1000*sec;
  redraw();
}

// Stop line movement reference
int MRef(int sl, int mv)
{
  return((sl<<3)|mv);
}

// Stop line movement reference
int MRefSl(int ref)
{
  return(ref>>3);
}
// Stop line movement reference
int MRefMv(int ref)
{
  return(ref&0x07);
}

// Vertex class (of stop line)
class Vertex
{
  float x;  // R B X pos
  float y;  // R B Y pos
  int vtr;  // Vertex size for dragging
  
  Vertex(float x1, float y1)
  {
    x = x1;
    y = y1;
    vtr = 5;
  }
  
  // Check if mouse over stop line Vertex
  Boolean Over(float xm, float ym)
  {
    if ( dist(xm,ym,x,y) < vtr )
      return(true);
    
    return(false);
  }
  
  void display()
  {
    ellipse(x,y,vtr,vtr);
    // rect(x-vtxsz,y-vtxsz,x+vtxsz,y+vtxsz);
  }
}

// Edge class
class Edge
{
  float xi;
  float yi;
  float xf;
  float yf;
  
  Edge(float x, float y, float ux, float uy, float sz)
  {
    xi = x;
    yi = y;
    xf = xi + ux*sz;
    yf = yi + uy*sz;
  }
  
  boolean over(float xm, float ym)
  {
    float s1, s2, z;
    
    z = (xf-xi)*(ym-yi) - (yf-yi)*(xm-xi);
    z /= dist(xi,yi,xf,yf);
    s1 = (xf-xi)*(xm-xi) + (yf-yi)*(ym-yi);
    s2 = (xf-xi)*(xm-xf) + (yf-yi)*(ym-yf);
    if ( (s1*s2 < 0) && (abs(z) < 10) )
      return(true);

    return(false);
  }
  
  void display(float w, color c)
  {
    pushStyle();
    strokeWeight(w);
    stroke(c);
    line(xi,yi,xf,yf);
    popStyle();
  }
}

// Rectangle class
class Rectangle
{
  float x;
  float y;
  float ux;
  float uy;
  float x1;
  float y1;
  float x2;
  float y2;
  float x3;
  float y3;
  float x4;
  float y4;
  float h;
  float l;
  
  Rectangle(float x, float y, float ux, float uy, float l, float h)
  {
    set(x,y,ux,uy,l,h);
  }
  
  void set(float x, float y, float ux, float uy, float l, float h)
  {
    this.x = x;
    this.y = y;
    this.ux = ux;
    this.uy = uy;
    x1 = x + ux*l/2 + uy*h/2;
    y1 = y + uy*l/2 - ux*h/2;
    x2 = x1 - ux*l;
    y2 = y1 - uy*l;
    x3 = x2 - uy*h;
    y3 = y2 + ux*h;
    x4 = x1 - uy*h;
    y4 = y1 + ux*h;
    this.l = l;
    this.h = h;
  }
  
  boolean over(float xm, float ym)
  {
    float z, w;
    
    z = (x4-x1)*(ym-y1) - (y4-y1)*(xm-x1);
    z /= h;
    w = (x4-x1)*(xm-x1) + (y4-y1)*(ym-y1);
    w /= h;
    if ( (w >= 0) && (w < l) && (z >= 0) && (z < h) )
      return(true);

    return(false);
  }
  
  void display(float w, color c)
  {
    pushStyle();
    strokeWeight(w);
    stroke(c);
    quad(x1,y1,x2,y2,x3,y3,x4,y4);
    //ellipse(x,y,3,3);
    popStyle();
  }

  void displayNew(float w, color c)
  {
    pushStyle();
    strokeWeight(w);
    stroke(c);
    quad(x1,y1,x2,y2,x3,y3,x4,y4);
    line(x-ux*4,y-uy*4,x+ux*4,y+uy*4);
    line(x-uy*4,y+ux*4,x+uy*4,y-ux*4);
    //ellipse(x,y,3,3);
    popStyle();
  }
}

// Loops class (data for each lane / movement)
class Loops
{
  int nl;
  int maxl;
  PVector u;
  Rectangle[] lp;
  boolean[] activated;
  int sel;

  Loops(int mxl)
  {
    nl = 0;
    u = new PVector(0,0);
    maxl = mxl;
    if ( maxl > 0 )
    {
      lp = new Rectangle[maxl];
      activated = new boolean[maxl];
      for ( int i=0 ; i<maxl ; i++ )
      {
        lp[i] = new Rectangle(0,0,0,0,0,0);
        activated[i] = false;
      }
    }
    
    sel = -1;
  }
  
  // Set loop size and location from stop line
  void set(float xl, float yl, float ux, float uy, float szl)
  {
    u.set(ux,uy);
    for ( int i=0 ; i<maxl ; i++ )
    {
      float x = xl - i*ux*(szl+6);
      float y = yl - i*uy*(szl+6);
      lp[i].set(x,y,ux,uy,szl,szl);
    }
  }
  
  void init()
  {
    nl = 0;
    sel = -1;
  }
  
  // Adds a new loop to the lane 
  void add()
  {
    if ( nl < maxl )
    {
      sel = nl;
      nl++;
    }
  }
  
  // Remove a loop from the lane
  void del()
  {
    if ( (sel >= 0) && (nl > 0) )
    {
      nl--;
      sel = -1;
    }
  }
  
  // Select a loop for editing
  void select(int n)
  {
    if ( n < nl )
    {
      if ( sel == n )
        sel = -1;
      else
        sel = n;
    }
  }
  
  // Unselect the loop
  void unselect()
  {
    sel = -1;
  }
  
  // Activate loop
  void activate(int n)
  {
    if ( n < nl )
      activated[n] = true;
  }
  
  // Reset all loops activation
  void reset(int n)
  {
    if ( n < nl )
      activated[n] = false;
  }
  
  // Checks point over a loop
  // Returns 1..n:Loop, 0:New, -1:No loop
  int over(float xm, float ym)
  {
    for ( int i=0 ; i<nl ; i++ )
    {
      if ( lp[i].over(xm,ym) )
        return(i+1);
    }

    // Check over 'New Loop'
    if ( nl < maxl )
    {
      if ( lp[nl].over(xm,ym) )
        return(0);
    }
    
    return(-1);
  }
  
  // Render loops in run mode
  void render()
  {
    color c;
    noFill();
    for ( int i=0 ; i<nl ; i++ )
    {
      if ( activated[i] )
      {
        c = color(255,0,0);
        lp[i].display(2,c);
      }
      else
      {
        c = color(100,100,50);
        lp[i].display(1,c);
      }
    }
  }

  // Display loops in edition mode
  void display()
  {
    color c;
    noFill();
    for ( int i=0 ; i<nl ; i++ )
    {
      if ( i == sel )
      {
        c = color(255,255,0);
        lp[i].display(2,c);
      }
      else
      {
        c = color(0,255,0);
        lp[i].display(1,c);
      }
    }

    if ( nl < maxl )
    {
      c = color(255,0,0);
      lp[nl].displayNew(1,c);
    }
  }
}

// Lane class
class Lane
{
  int type;  // 0:Unknown, 1:Left, 2:Front, 4:Right
  float x;
  float y;
  float ux;
  float uy;
  float xa;
  float ya;
  float xc;
  float yc;
  float sz;
  float ang;
  
  Lane()
  {
    reset();
  }
  
  void reset()
  {
    type = FRONT_MOV;  // Front by default
    x = 0;
    y = 0;
    xa = 0;
    ya = 0;
    xc = 0;
    yc = 0;
    ux = 0;
    uy = 0;
    sz = 0;
    ang = 0;
  }
  
  void setPos(float x, float y, float ux, float uy, float ang, float sz)
  {
    this.x = x;
    this.y = y;
    this.ux = ux;
    this.uy = uy;
    this.sz = sz;
    this.ang = ang;
    xa = x - 2*sz*ux;
    ya = y - 2*sz*uy;
    xc = x - 3*sz*ux/2;
    yc = y - 3*sz*uy/2;
  }
  
  void setSize(float sz)
  {
    this.sz = sz;
    xa = x - 2*sz*ux;
    ya = y - 2*sz*uy;
    xc = x - 3*sz*ux/2;
    yc = y - 3*sz*uy/2;
  }
  
  void setType(int t)
  {
    type = t;
  }
  
  boolean over(float xm, float ym)
  {
    float d = dist(xm,ym,xc,yc);
    if ( d < sz/2 )
      return(true);
    
    return(false);
  }
  
  void display(color c)
  {
    //pushStyle();
    //strokeWeight(3);
    //color c = color(R,G,B);
    //stroke(c);
    //noFill();
    //ellipse(xc,yc,sz/2,sz/2);
    switch ( int(type) )  // $$$
    {
      case 1:  // Left arrow
        DrawArrow(xa,ya,ang,Arl,c,sz);
        break;

      case 2:  // Front arrow
        DrawArrow(xa,ya,ang,Arf,c,sz);
        break;

      case 4:  // Right arrow
        DrawArrow(xa,ya,ang,Arr,c,sz);
        break;
    }
    //popStyle();
  }
}

// Traffic Light Movement
class Tlmov
{
  int type;  // 0:Unknown, 1:Left, 2:Front, 4:Right
  int nl;
  float x;
  float y;
  float ux;
  float uy;
  float sz;
  float ang;
  boolean blinkon;
  int msblink;
  boolean loops;
  Loops l;
  float lofs;
 
  Tlmov()
  {
    l = new Loops(2);
    reset();
  }
  
  void reset()
  {
    this.type = 0;
    this.nl = 0;
    this.x = 0;
    this.y = 0;
    this.ux = 0;
    this.uy = 0;
    this.sz = 0;
    this.ang = 0;
    blinkon = false;
    msblink = 0;
    loops = false;
    l.init();
  }
  
  // Set traffic light movement position and direction
  void setPos(int type, int nl, float x, float y, float ux, float uy, float ang, float sz)
  {
    this.type = type;
    this.nl = nl;
    this.x = x;
    this.y = y;
    this.ux = ux;
    this.uy = uy;
    this.ang = ang;
    
    setSize(sz);
  }
  
  void setSize(float sz)
  {
    this.sz = sz;
    
    // Set loops position
    lofs = 3*sz;
    l.set(x-ux*lofs,y-uy*lofs,ux,uy,sz);
  }
  
  // Checks over tlm
  boolean over(float xm, float ym)
  {
    /*
    Rectangle r = new Rectangle(x-ux*sz,y-uy*sz,ux,uy,2*sz,nl*sz);
    if ( r.over(xm,ym) == true )
      return(true);
    */
    if ( dist(x,y,xm,ym) < sz/2 )
      return(true);
    
    return(false);
  }
  
  // Add loop
  void addLoop(float x, float y, float ux, float uy, float sz)
  {
    if ( l.nl < 2 )
      l.lp[l.nl++].set(x,y,ux,uy,sz,sz);

    loops = true;
  }
  
  // Over loop N:1..4, 0:New, -1:No loop
  int overLoop(float xm, float ym)
  {
    if ( loops )
      return(l.over(xm,ym));
    
    return(-1);
  }
  
  // Draw movement arrows
  void drawArrows(color c)
  {
    // Old float xi = x + uy*sz*(nl+1)/2 + ux*sz/4;
    // Old float yi = y - ux*sz*(nl+1)/2 + uy*sz/4;

    float xi = x + uy*sz*(nl+1)/2 - 2*sz*ux;
    float yi = y - ux*sz*(nl+1)/2 - 2*sz*uy;
    for ( int i=0 ; i<nl ; i++ )
    {
      xi += -uy*sz;
      yi += ux*sz;
      switch ( int(type) )  // $$$
      {
        case 1:  // Left arrow
          DrawArrow(xi,yi,ang,Arl,c,sz);
          break;
  
        case 2:  // Front arrow
          DrawArrow(xi,yi,ang,Arf,c,sz);
          break;
  
        case 4:  // Right arrow
          DrawArrow(xi,yi,ang,Arr,c,sz);
          break;
      }
    }
  }

  // Render movement arrows and loops
  void render(color c)
  {
    drawArrows(c);
    
    if ( loops )
      l.render();
  }
  
  // Display movement loops in edition mode
  void displayLoops()
  {
    if ( loops )
      l.display();
  }

  // Display movement lanes in edition mode
  void display(color c)
  {
    //color c = color(R,G,B);
    /*
    noFill();
    Rectangle r = new Rectangle(x-ux*sz,y-uy*sz,ux,uy,2*sz,nl*sz);
    r.display(1,c);
    */
    //ellipse(xo,yo,sz/2,sz/2);

    stroke(c);
    // Render arrows
    render(c);
    
    //strokeWeight(4);
    /*
    float xi = x + uy*sz*(4*nl-1)/8 + ux*1.9*sz;
    float yi = y - ux*sz*(4*nl-1)/8 + uy*1.9*sz;
    float xf = xi - uy*sz*(8*nl-1)/8;
    float yf = yi + ux*sz*(8*nl-1)/8;
    line(xi,yi,xf,yf);
    */
    noFill();
    stroke(c);
    strokeWeight(1);
    ellipse(x,y,sz/2,sz/2);
  }
}

// Class for access point (entry or exit)
class AccessPoint
{
  float xo;
  float yo;
  float x;
  float y;
  float r;
  float l;
  
  AccessPoint()
  {
    this.xo = 0;
    this.yo = 0;
    this.x = 0;
    this.y = 0;
    this.r = 0;
    this.l = 0;
  }
  
  void set(float x, float y, float ux, float uy, float r, float l)
  {
    this.xo = x;
    this.yo = y;
    this.x = x + ux*l;
    this.y = y + uy*l;
    this.r = r;
    this.l = l;
  }
  
  boolean over(float xm, float ym)
  {
    if ( r == 0 )
      return(false);
      
    if ( dist(x,y,xm,ym) < r )
      return(true);
    
    return(false);
  }
  
  void display(color c)
  {
    if ( r > 0 )
    {
      fill(c,70);
      stroke(c);
      line(xo,yo,x,y);
      ellipse(x,y,r,r);
    }   
  }
}

// StopLine class
class StopLine
{
  Vertex[] c = new Vertex[2];  // StopLine end points
  Vertex[] csave = new Vertex[2];  // Saved stop line to restore changes
  float U = 0;    // Stop line length
  float Ang = 0;  // Angle
  float ux = 0;   // Unit vector x
  float uy = 0;   // Unit vector y
  int nl;  // Number of lanes
  Boolean selected;  // Stop line selected
  Boolean invalid;   // Invalid shape
  Boolean isave;     // Invalid save
  int dragmode;      // 0:No drag, 1:End point, 2:Edge, 3:Resize, 4: Shape
  int dragitem;      // Vertex or edge index
  float savex = 0;
  float savey = 0;
  Boolean del;    // Deleted ?
  Boolean main;  // Main stop line flag (the first one)
  String ids;     // Stop line id
  int type;    // Access type (0:Unknown, 1:Entry, 2:Exit, 3:Intermediate)
  Lane[] ln = new Lane[Maxln];  // Lane types
  int nm;
  Tlmov[] tlm = new Tlmov[3];  // Traffic light movements (heads), max 3
  AccessPoint[] acp = new AccessPoint[3];  // Access points, max 3

  
  StopLine(Vertex ini, Vertex end)
  {
    c[0] = new Vertex(ini.x,ini.y);
    c[1] = new Vertex(end.x,end.y);

    csave[0] = new Vertex(ini.x,ini.y);
    csave[1] = new Vertex(end.x,end.y);

    selected = false;
    invalid = true;
    dragmode = 0;
    del = false;
    if ( Nsl == 0 )
      main = true;
    else
      main = false;
    // ids = "#"+Nsl;  // ?????
    nl = 0;
    type = 0;
    
    for ( int i=0 ; i<Maxln ; i++ )
      ln[i] = new Lane();

    nm = 0;
    for ( int i=0 ; i<3 ; i++ )
    {
      tlm[i] = new Tlmov();
      acp[i] = new AccessPoint();
    }
    
    // Update stop line data
    update();
    
    Changes = true;
  }
  
  // Updates stop line vector when vertex changes
  void update()
  {
    U = dist(c[0].x,c[0].y,c[1].x,c[1].y);
    ux = (c[1].x - c[0].x) / U;
    uy = (c[1].y - c[0].y) / U;
    Ang = atan(-ux/uy);
    if ( ux > 0 )
    {
      if ( uy >= 0 )
        Ang += PI;
    }
    else
    {
      if ( uy >= 0 )
        Ang += PI;
      else
        Ang += 2*PI;
    }
/*
    if ( Lsz != 0 )
    {
       if ( main == true )
         setLanes(nl);
       else
         nl = int(U/Lsz);
    }
*/
    updateLanes();
  }
  
  // Update lanes data when something changes
  void updateLanes()
  {
    float xl = c[0].x - ux*Lsz/2;
    float yl = c[0].y - uy*Lsz/2;
    println("Maxl , Nl: "+Maxln+" , "+nl);
    for ( int i=0 ; i<nl ; i++ )
    {
      xl += ux*Lsz;
      yl += uy*Lsz;
      ln[i].setPos(xl,yl,-uy,ux,Ang,Lsz);
    }
    
    updateTlmov();
  }
  
  // Update traffic light movements when lanes change
  void updateTlmov()
  {
    nm = 0;
    int i = 0;
    while ( (i < nl) && (nm < 3) )
    {
      int j = i + 1;
      while ( j < nl )
      {
        if ( ln[j].type != ln[i].type )
          break;
        
        j++;
      }
    
      float xm = (ln[i].x + ln[j-1].x)/2;
      float ym = (ln[i].y + ln[j-1].y)/2;
      tlm[nm].setPos(ln[i].type,(j-i),xm,ym,-uy,ux,Ang,Lsz);
      
      // Now update access points
      switch ( int(type) )
      {
        case 1: // Entry
          acp[nm].set(xm,ym,uy,-ux,10,100);
          break;
          
        case 2: // Exit
          acp[nm].set(xm,ym,-uy,ux,10,100);
          break;
          
        default:
          acp[nm].set(xm,ym,0,0,0,0);
          break;
      }
      
      nm++;
      i = j;
    }
  }
  
  // Updates stop line size when lane size changes
  void updateSize()
  {
    U = Lsz*nl;
    c[1].x = c[0].x + ux*U;
    c[1].y = c[0].y + uy*U;
    
    updateLanes();
  }
  
  // Set stop lane type
  void setType(int t)
  {
    type |= t;
    
    switch ( int(type) )
    {
      case 1:  // Entry
      case 2:  // Exit
        // Only entry allows loops
        for ( int i=0 ; i<3 ; i++ )
        {
          float x = tlm[i].x;
          float y = tlm[i].y;
          if ( type == 1 )
          {
            tlm[i].loops = true;
            acp[i].set(x,y,uy,-ux,10,100);
          }
          else
            acp[i].set(x,y,-uy,ux,10,100);
        }
        break;
      
      default:
        for ( int i=0 ; i<3 ; i++ )
          tlm[i].loops = false;
        break;
    }
  }
    
  void setVertex(int i, float xm, float ym)
  {
    c[i].x = xm;
    c[i].y = ym;
    update();
    Changes = true;
  }
  
  void Select()
  {
    selected = true;
  }

  void unSelect()
  {
    selected = false;
  }

  void setLanes(int l)
  {
    float ls;
    
    ls = U / l;
    if ( ls >= 8 )
    {
      if ( l <= Maxln )
      {
        nl = l;
        Lsz = ls;
      }
      else
      {
        nl = Maxln;
        Lsz = U / nl;
      }
    }
    
    println("Set lanes "+nl);
    update();   
  }
  
  // Get lane movement
  int getTlm(int l)
  {
    if ( del == false )
    {
      int accl = 0;
      for ( int i=0 ; i<nm ; i++ )
      {
        if ( l < tlm[i].nl + accl )
          return(i);
        
        accl += tlm[i].nl;
      }
    }
    
    return(0);
  }
  
  // Change lane movement type, if possible
  boolean chgType(int l)
  {
    int rt, lt;
    
    // Determines movements at both sides
    if ( l > 0 )
      rt = ln[l-1].type;
    else
      rt = RIGHT_MOV;
    
    if ( l < nl - 1 )
      lt = ln[l+1].type;
    else
      lt = LEFT_MOV;
    
    // Calculates a combined value for the possible configurations
    int stat = lt + 2*rt;
    if ( stat == 6 )  // Both sides Front
      return(false);

    //println("LT: "+lt+" RT: "+rt+"  Type: "+ln[l].type);
    switch ( int(stat) )
    {
      case 5:  // Front and Right
      case 10:  // Left and Front
        if ( ln[l].type == lt )
          ln[l].type = rt;
        else
          ln[l].type = lt;
        break;

      case 9:  // Left and Right
        if ( ln[l].type == lt )
          ln[l].type = FRONT_MOV;
        else if ( ln[l].type == rt )
          ln[l].type = LEFT_MOV;
        else
          ln[l].type = RIGHT_MOV;
        break;
    }

    // Update traffic light movements
    updateTlmov();    

    return(true);
  }

  // Saves current shape data
  void saveCoords()
  {
    for ( int i=0 ; i<2 ; i++ )
    {
      csave[i].x = c[i].x;
      csave[i].y = c[i].y;
    }
    
    isave = invalid;
  }
  
  // Restores shape data (before dragged)
  void Restore()
  {
    for ( int i=0 ; i<2 ; i++ )
    {
      c[i].x = csave[i].x;
      c[i].y = csave[i].y;
    }
    
    update();
    
    invalid = isave;
  }
  
  // Check if mouse over any stop line Vertex
  int overVertex(float xm, float ym)
  {
    if ( del == false )
    {
      for ( int i=0 ; i<2 ; i++ )
        if ( c[i].Over(xm,ym) == true )
          return(i);
    }
    
    return(-1);
  }
  
  // Check if mouse over stop line edge
  boolean overEdge(float xm, float ym)
  {
    float z;
    float s1;
    float s2;
    
    if ( del == false )
    {
      z = (c[1].x-c[0].x)*(ym-c[0].y) - (c[1].y-c[0].y)*(xm-c[0].x);
      z /= dist(c[0].x,c[0].y,c[1].x,c[1].y);
      s1 = (c[1].x-c[0].x)*(xm-c[0].x) + (c[1].y-c[0].y)*(ym-c[0].y);
      s2 = (c[1].x-c[0].x)*(xm-c[1].x) + (c[1].y-c[0].y)*(ym-c[1].y);
      if ( (s1*s2 < 0) && (abs(z) < 10) )
        return(true);
    }
    
    return(false);
  }
  
  // Check if mouse over a lane symbol
  int overLane(float xm, float ym)
  {
    if ( del == false )
    {
      for ( int i=0 ; i<nl ; i++ )
        if ( ln[i].over(xm,ym) == true )
          return(i);
    }
    
    return(-1);
  }
  
  // Check if mouse over access point
  int overAccess(float xm, float ym)
  {
    if ( (type == 1) || (type == 2) )
    {
      for ( int i=0 ; i<3 ; i++ )
      {
        if ( acp[i].over(xm,ym) )
          return(i);
      }
    }
    
    return(-1);
  }
  
  // Check if mouse over traffic light movement
  int overTlmv(float xm, float ym)
  {
    if ( del == false )
    {
      for ( int i=0 ; i<nm ; i++ )
      {
        if ( tlm[i].over(xm,ym) == true )
          return(i);
      }
    }
    
    return(-1);
  }
  
  // Check if mouse over loop
  // Returns: (loop<<2) | tlm
  int overLoop(float xm, float ym)
  {
    if ( del == false )
    {
      for ( int i=0 ; i<nm ; i++ )
      {
        int l = tlm[i].overLoop(xm,ym);
        if ( l >= 0 )
          return((l<<2)|i);
      }
    }
    
    return(-1);
  }
  
  // Unselect loops
  void unselectLoops()
  {
    if ( del == false )
    {
      for ( int i=0 ; i<nm ; i++ )
      {
        if ( tlm[i].loops )
          tlm[i].l.unselect();
      }
    }
  }

  // Delete selected loop, if any
  void deleteLoop()
  {
    if ( del == false )
    {
      for ( int i=0 ; i<nm ; i++ )
      {
        if ( tlm[i].loops )
          tlm[i].l.del();
      }
    }
  }

  // Set drag mode 'Vertex'
  void dragVertex(int item, float xm, float ym)
  {
    dragmode = 1;
    dragitem = item;
    savex = xm;
    savey = ym;
    saveCoords();
  }
  
  // Set drag mode 'edge'
  void dragEdge(float xm, float ym)
  {
    dragmode = 2;
    dragitem = 2;
    savex = xm;
    savey = ym;
    saveCoords();
  }
  
  // Drag to new position according to mode
  void Drag(float xm, float ym)
  {
    float incx = xm - savex;
    float incy = ym - savey;
    
    savex = xm;
    savey = ym;
    switch ( int(dragmode) )
    {
      case 1:  // Vertex
        c[dragitem].x += incx;
        c[dragitem].y += incy;
        update();
        if ( Lsz != 0 )
        {
           if ( main == true )
             setLanes(nl);
           else
           {
             int l = int(U/Lsz);
             if ( l <= Maxln )
               nl = l;
           }
           
           updateLanes();
        }
        Changes = true;
        break;
        
      case 2:  // Edge
        c[0].x += incx;
        c[0].y += incy;
        c[1].x += incx;
        c[1].y += incy;
        update();
        //updateLanes();
        Changes = true;
        break;
        
    }
    
    if ( chkValid() )
    {
      if ( (BackMode != 0) && (BackMode != 3) )
        RenderMovementsPG();  // !!!
    }
  }
  
  // Move stop line
  void moveShape(float incx, float incy)
  {
    saveCoords();
    for ( int i=0 ; i<2 ; i++ )
    {
      c[i].x += incx;
      c[i].y += incy;
    }

    chkValid();
    if ( invalid )
    {
      Restore();
    }
    else
    {
      update();
      //updateLanes();
      Changes = true;
                
      if ( (BackMode != 0) && (BackMode != 3) )
        RenderMovementsPG();  // !!!
    }
  }
  
  // Checks if stop line shape is valid ?
  boolean chkValid()
  {
    // Checks vertex inside window
    for ( int i=0 ; i<2 ; i++ )
    {
      if ( (c[i].x < 0) || (c[i].x >= width) )
      {
        invalid = true;
        return(false);
      }
      if ( (c[i].y < HeaderH) || (c[i].y >= height-FooterH) )
      {
        invalid = true;
        return(false);
      }
    }    

    // Checks stop lines overlapping (cross lines) !!!!
    
    // Checks stop line size (too small not allowed)
    float d = dist(c[0].x,c[0].y,c[1].x,c[1].y);
    if ( (d < 0.9*Lsz) || (d < 8) )
    {
      invalid = true;
      return(false);
    }
      
    invalid = false;
    return(true);
  }
  
  // Release dragging (drop)
  Boolean Release()
  {
    dragmode = 0;
    
    // If shape invalid then restore previous shape data
    if ( invalid )
      Restore();
    
    // If still invalid then delete the shape
    if ( invalid )
    {
      del = true;
      Changes = true;
      return(true);
    }
    
    // Adjusts stop line size to number of lanes
    if ( Lsz > 0 )
      updateSize();
    
    return(false);
  }


  // Draw lanes in edit mode (arrow movements)
  void drawLanes(color col)
  {
    if ( del == false )
    {
      for ( int i=0 ; i<nl ; i++ )
        ln[i].display(col);

      for ( int i=0 ; i<nm ; i++ )
        tlm[i].displayLoops();
    }
  }

  // Draw traffic light movements
  void drawAccess(color col)
  {
    if ( del == false )
    {
      pushStyle();
      strokeWeight(4);
      //stroke(R,G,B);
      stroke(col);
      line(c[0].x,c[0].y,c[1].x,c[1].y);
      
      for ( int i=0 ; i<nm ; i++ )
        tlm[i].display(col);
      
      strokeWeight(1);
      for ( int i=0 ; i<nm ; i++ )
      {
        if ( (type == 1) || (type == 2) )
          acp[i].display(col);
      }

      popStyle();
    }
  }

  // Render stop line movement (detailed or compact depending on scale)
  void renderMov(int m, int t, float sz)
  {
    color col;
    
    if ( del == false )
    {
      switch ( int(t) )
      {
        case 0:  // Red
          // Orange transition !!!
          col = color(250,0,0);
          break;
        
        case 1:  // Green
          col = color(0,250,50);
          break;
        
        case 2:  // Orange (blinking)
          int ms = millis();
          if ( ms > tlm[m].msblink )
          {
            if ( tlm[m].blinkon )
              tlm[m].blinkon = false;
            else
              tlm[m].blinkon = true;
            
            tlm[m].msblink = ms + 500;
          }

          if ( tlm[m].blinkon )
            col = color(250,220,0);
          else
            col = color(50,20,0);
          break;
        
        default:
          col = color(250,0,0);
          break;
      }

      //if ( Mode3D )
        //translate(0,0,1);

      if ( Scale >= 1 )
      {
        // Full lane details
        tlm[m].render(col);
        drawSL(color(250,250,0));
      }
      else
      {
        // Only main phase movements
        if ( (type == 1) && (t == 1) )
        {
          // Entry Access and green movement
          float xa = (c[0].x + c[1].x)*Scale/2 + width*(1-Scale)/2;
          float ya = (c[0].y + c[1].y)*Scale/2 + height*(1-Scale)/2;
          switch ( int(tlm[m].type) )
          {
            case 1:  // Left arrow
              DrawArrow(xa,ya,Ang,Arl,col,sz);
              break;
      
            case 2:  // Front arrow
              DrawArrow(xa,ya,Ang,Arf,col,sz);
              break;
      
            case 4:  // Right arrow
              DrawArrow(xa,ya,Ang,Arr,col,sz);
              break;
          }
        }
      }

      //if ( Mode3D )
        //translate(0,0,-1);
    }
  }
  
  // Draw stop line
  void drawSL(color col)
  {
    stroke(col);
    strokeWeight(4);
    line(c[0].x,c[0].y,c[1].x,c[1].y);
    strokeWeight(1);
  }

  // Calculates distance to other stop line
  float distance(int s)
  {
    float dx = Sl[s].c[0].x - c[0].x;
    float dy = Sl[s].c[0].y - c[0].y;

    return(sqrt(dx*dx+dy*dy));
  }
  
  // Calculates distance to crossing point with other access link
  float crossDistance(int s)
  {
    float v1x;
    float v1y;
    float v2x;
    float v2y;
    if ( type == 1 )  // Entry
    {
      v1x = -uy;
      v1y = ux;
    }
    else  // Exit
    {
      v1x = uy;
      v1y = -ux;
    }
    
    if ( Sl[s].type == 1 )  // Entry
    {
      v2x = -Sl[s].uy;
      v2y = Sl[s].ux;
    }
    else  // Exit
    {
      v2x = Sl[s].uy;
      v2y = -Sl[s].ux;
    }
    
    float x1 = (c[0].x + c[1].x)/2;
    float y1 = (c[0].y + c[1].y)/2;
    float x2 = (Sl[s].c[0].x + Sl[s].c[1].x)/2;
    float y2 = (Sl[s].c[0].y + Sl[s].c[1].y)/2;
    float sen = v1x*v2y - v2x*v1y;
    if ( sen == 0 )
      return(0);
      
    float d = ((v2y*x2-v2x*y2) - (v2y*x1-v2x*y1))/sen;

    return(d); //<>//
  }
  
  // Calculates gap with a reverse direction SL in same access point
  float gap()
  {
    for ( int i=0 ; i<Maxsl ; i++ )
    {
      if ( (Sl[i].del == false) && (Sl[i].type == 1) )
      {
        float cos = ux*Sl[i].ux + uy*Sl[i].uy;
        float g = (Sl[i].c[0].y-c[0].y)*ux - (Sl[i].c[0].x-c[0].x)*uy;
        float s = (Sl[i].c[0].x-c[0].x)*ux + (Sl[i].c[0].y-c[0].y)*uy - Sl[i].U - U;
        //println(" -> "+i+" cos: "+cos+" , gap: "+g+" , s: "+s+" Lsz: "+Lsz);
        if ( (cos < -0.95) && (g < 6*Lsz) && (g > 0) && (s < Lsz) )
          return(g);
      }
    }
    
    return(0);
  }
  
  // Draw stop line in edition mode
  void display()
  {
    color col;
    
    if ( del == false )
    {
      pushStyle();
      if ( Mode != 2 )  // Edit
      {
        if ( invalid )
          col = color(255,50,50);
        else
        {
          if ( main == true )
            col = color(50,255,100);
          else
            col = color(255,255,50);
        }
  
        if ( Lsz != 0 )
        {
          fill(col);
          noStroke();
          if ( Mode == 0 )  // Mode: Edit stop line
          {
            drawSL(col);
            drawLanes(col);
          }
          else              // Mode: Edit movements
            drawAccess(col);
        }
        else
          drawSL(col);
  
        if ( selected == true )
        {
          noStroke();
          fill(col,255);
          for ( int i=0 ; i<2 ; i++ )
            c[i].display();
        }
        
        /*
        if ( invalid == false )
        {
          float xc = (c[0].x+c[1].x)/2;
          float yc = (c[0].y+c[1].y)/2;
          // fill(R-30,G-30,B-30,255);
          // rect(xc-20,yc-10,xc+20,yc+10);
          fill(255,255,255,255);
          text(ids,xc,yc);
        }
        */
      }
      
      popStyle();
    }
  }
}

// Movement class, defines a movement between two stop lines
class Movement
{
  int si;  // Start stop line 
  int mi;   // Start traffic light movement
  int sf;  // End stop line
  int mf;   // End traffic light movement
  //int type;    // 0x00: Undef, 0x01:Left, 0x02:Front, 0x04:Right
  boolean del; // Deleted
  boolean sel; // Selected
  float xf;    // Movement ende point while dragging
  float yf;
  PVector cpi;  // Start control point
  PVector cpf;  // End control point
  PVector cpm;  // Middle control point
  int selcp;    // Selected control point
  PVector cpback;
  
  /* No soportado en js
  Movement()
  {
    del = true;
    si = -1;
    mi = -1;
    sf = -1;
    mf = -1;
    sel = false;
    selcp = -1;
    
    cpi = new PVector(0,0);
    cpf = new PVector(0,0);
    cpm = new PVector(0,0);
    cpback = new PVector(0,0);
  }
  */
  
  Movement(int i, int f)
  {
    if ( (i < 0) && (f < 0) )
    {
      del = true;
      si = -1;
      mi = -1;
      sel = false;
      selcp = -1;
    }
    else
    {
      si = MRefSl(i);
      mi = MRefMv(i);
      //Sl[si].setType(0x01);  // Entry access
      del = false;
      sel = false;
      selcp = -1;
      //type = Sl[si].tlm[mi].type;
    }

    cpi = new PVector(0,0);
    cpf = new PVector(0,0);
    cpm = new PVector(0,0);
    cpback = new PVector(0,0);

    sf = -1;
    mf = -1;
    if ( f >= 0 )
      set(f);
  }
  
  // Sets movement end point (stop line)
  // Updates stop line type, 0x01:Entry, 0x02:Exit, 0x03:Both
  boolean set(int f)
  {
    int slf = MRefSl(f);
    int slmf = MRefMv(f);

    if ( ((si != slf) && (mi < 3) && (slmf < 3)) || ((si == slf) && (mi < 3) && (slmf >= 3)) )
    {
      // Valid combination, set end point data
      sf = slf;
      mf = slmf;
      //type = Sl[si].tlm[mi].type;
      println("Set Mv: "+si+" , "+mi+" , "+sf+" , "+mf);

      // Set default rendering control points
      initControlPoints();

      if ( mf < 3 )
      {
        Sl[si].setType(0x01);  // Start point
        Sl[sf].setType(0x02);  // End point
      }
      
      return(true);
    }

      // Invalid combination
    del = true;
    sel = false;
    
    return(false);
  }
  
  // Reset
  void reset()
  {
    del = true;
    si = -1;
    mi = -1;
    sel = false;
    selcp = -1;
    
    cpi.set(0,0,0);
    cpf.set(0,0,0);
    cpm.set(0,0,0);
    cpback.set(0,0,0);

    sf = -1;
    mf = -1;
  }
  
  // Update movement data (mid control point)
  void update()
  {
    float xi, yi;
    float xf, yf;
    
    if ( mi > 2 )
    {
      xi = Sl[si].acp[mi-3].x;
      yi = Sl[si].acp[mi-3].y;
    }
    else
    {
      xi = Sl[si].tlm[mi].x;  // xo
      yi = Sl[si].tlm[mi].y;
    }
  
    if ( mf > 2 )
    {
      xf = Sl[sf].acp[mf-3].x;
      yf = Sl[sf].acp[mf-3].y;
    }
    else
    {
      xf = Sl[sf].tlm[mf].x;
      yf = Sl[sf].tlm[mf].y;
    }
    
    if ( (mi > 2 ) || (mf > 2) )
    {
      // Only mid point
      cpm.x = (xi + xf)/2;
      cpm.y = (yi + yf)/2;
    }
    else
    {
      cpm.x = bezierPoint(xi, xi+cpi.x, xf+cpf.x, xf, 0.5);
      cpm.y = bezierPoint(yi, yi+cpi.y, yf+cpf.y, yf, 0.5);
    }
  }
  
  // Checks if movement includes a stop line
  boolean hasValue(int s)
  {
    if ( del == false )
    {
      if ( (si == s) || (sf == s) )
        return(true);
    }
    return(false);
  }

  // Drag movement line to x,y
  void drag(int x, int y)
  {
    xf = x;
    if ( (y > HeaderH) && (y < height-FooterH) )
      yf = y;
  }
  
  // Checks if click on the movement line //
  boolean over(float xm, float ym)
  {
    if ( del == false )
    {
      if ( dist(xm,ym,cpm.x,cpm.y) <= 11 )
        return(true);
    }
    
    return(false);
  }
  
  // Checks if click on the control points
  int overControlPoint(float xm, float ym)
  {
    float x;
    float y;
    
    if ( (sf > 0) && (mf < 3) && (si >= 0) && (mi < 3) )
    {
      x = Sl[si].tlm[mi].x;  // xo
      y = Sl[si].tlm[mi].y;
      if ( dist(xm,ym,x+cpi.x,y+cpi.y) < 5 )
        return(0);
    
      if ( (sf >= 0) && (mf < 3) )
      {
        x = Sl[sf].tlm[mf].x;
        y = Sl[sf].tlm[mf].y;
        if ( dist(xm,ym,x+cpf.x,y+cpf.y) < 5 )
          return(1);
      }
    }
    
    return(-1);
  }
  
  // Drop selected control point
  void dropControlPoint(int xm, int ym)
  {
    // Check screen limits
    if ( (xm < 0) || (xm >= width) || (ym < HeaderH) || (ym >= height-FooterH) )
    {
      if ( selcp >= 0 )
        updateControlPoint(cpback.x,cpback.y);
      selcp = -1;
      return;
    }
    
    // Check size
    switch ( int(selcp) )
    {
      case 0:
        if ( cpi.mag() < 10 )
        {
          cpi.setMag(10);
          break;
        }
        
      case 1:
        if ( cpf.mag() < 10 )
        {
          cpf.setMag(10);
          break;
        }
    }

    selcp = -1;
  }
  
  // Drag selected control point, if any
  void dragControlPoint(float xm, float ym)
  {
    updateControlPoint(xm,ym);
        
    if ( (BackMode != 0) && (BackMode != 3) )
      RenderMovementsPG();  // !!!
  }
  
  // Selects control point for dragging
  void selControlPoint(int cp)
  {
    switch ( int(cp) )
    {
      case 0:
        selcp = 0;
        cpback.set(cpi);
        break;
      
      case 1:
        selcp = 1;
        cpback.set(cpf);
        break;
      
      default:
        selcp = -1;
        break;
    }
  }
  
  // Selects control point for dragging
  void unselControlPoint()
  {
    selcp = -1;
  }
    
  // Init control points based on path geometry
  void initControlPoints()
  {
    float xi, yi;
    float xf, yf;
    float vx, vy;
    float di, df;
    
    if ( sf < 0 )
      return;

    if ( mi > 2 )
    {
      xi = Sl[si].acp[mi-3].x;
      yi = Sl[si].acp[mi-3].y;
    }
    else
    {
      xi = Sl[si].tlm[mi].x;  // xo
      yi = Sl[si].tlm[mi].y;
    }
    
    if ( mf > 2 )
    {
      xf = Sl[sf].acp[mf-3].x;
      yf = Sl[sf].acp[mf-3].y;
    }
    else
    {
      xf = Sl[sf].tlm[mf].x;
      yf = Sl[sf].tlm[mf].y;
    }
    
    if ( (mi > 2 ) || (mf > 2) )
    {
      // Only mid point
      cpm.x = (xi + xf)/2;
      cpm.y = (yi + yf)/2;

      return;
    }

    // It is not an access path      
    di = Sl[si].crossDistance(sf);
    df = Sl[sf].crossDistance(si);
    float d = Sl[sf].distance(si);
    if ( (di < 0) || (df < 0) || (di > d) || (df > d) )
    {
      di = d/2;
      df = d/2;
    }

    vx = -Sl[si].uy;
    vy = Sl[si].ux;
    cpi.set(vx*di,vy*di);
    vx = -Sl[sf].uy;
    vy = Sl[sf].ux;
    cpf.set(-vx*df,-vy*df);

    // Set mid point
    cpm.x = bezierPoint(xi, xi+cpi.x, xf+cpf.x, xf, 0.5);
    cpm.y = bezierPoint(yi, yi+cpi.y, yf+cpf.y, yf, 0.5);
  }
  
  // Set control points
  void setControlPoints(float xr, float yr, float xs, float ys)
  {
    float xi, yi;
    float xf, yf;
    
    if ( sf < 0 )
      return;
      
    if ( mi > 2 )
    {
      xi = Sl[si].acp[mi-3].x;
      yi = Sl[si].acp[mi-3].y;
    }
    else
    {
      xi = Sl[si].tlm[mi].x;  // xo
      yi = Sl[si].tlm[mi].y;
    }
  
    if ( mf > 2 )
    {
      xf = Sl[sf].acp[mf-3].x;
      yf = Sl[sf].acp[mf-3].y;
    }
    else
    {
      xf = Sl[sf].tlm[mf].x;
      yf = Sl[sf].tlm[mf].y;
    }
    
    if ( (mi > 2 ) || (mf > 2) )
    {
      // Only mid point
      cpm.x = (xi + xf)/2;
      cpm.y = (yi + yf)/2;

      return;
    }

    cpi.set(xr,yr);
    cpf.set(xs,ys);

    // Set mid point
    cpm.x = bezierPoint(xi, xi+cpi.x, xf+cpf.x, xf, 0.5);
    cpm.y = bezierPoint(yi, yi+cpi.y, yf+cpf.y, yf, 0.5);
  }
  
  // Update selected control point
  void updateControlPoint(float xm, float ym)
  {
    float xi, yi;
    float xf, yf;
    
    if ( (si < 0) || (mi > 2) || (sf < 0) || (mf > 2) )
      return;
      
    xi = Sl[si].tlm[mi].x;  // xo
    yi = Sl[si].tlm[mi].y;
    xf = Sl[sf].tlm[mf].x;
    yf = Sl[sf].tlm[mf].y;
    switch ( int(selcp) )
    {
      case 0:  // Start
        cpi.set(xm-xi,ym-yi);
        break;

      case 1:  // End
        cpf.set(xm-xf,ym-yf);
        break;

      default:
        break;
    }
    
    // Set mid point
    cpm.x = bezierPoint(xi, xi+cpi.x, xf+cpf.x, xf, 0.5);
    cpm.y = bezierPoint(yi, yi+cpi.y, yf+cpf.y, yf, 0.5);
  }
  
  // Render movement path using Bezier curve
  void renderPath(PGraphics pg)
  {
    float vx;
    float vy;
    float xa;
    float ya;
    float xb;
    float yb;
    float xs;
    float ys;
    float xr;
    float yr;
    
    if ( (del == true) || (sf < 0) )
      return;
      
    pg.pushStyle();
    pg.noFill();
    pg.stroke(130,130,130);

    if ( (mi > 2) || (mf > 2) )
    {
      // Access path
      float w = (Sl[si].tlm[mi].nl+1)*Lsz;
      pg.strokeWeight(w);
      if ( mi > 2 )
      {
        xa = Sl[si].acp[mi-3].x;
        ya = Sl[si].acp[mi-3].y;
        xb = Sl[sf].tlm[mf].x;
        yb = Sl[sf].tlm[mf].y;
      }
      else
      {
        xa = Sl[si].tlm[mi].x;
        ya = Sl[si].tlm[mi].y;
        xb = Sl[sf].acp[mf-3].x;
        yb = Sl[sf].acp[mf-3].y;
      }
      pg.line(xa,ya,xb,yb);
    }
    else
    {
      // Link path
      float w1 = (Sl[si].tlm[mi].nl+1)*Lsz;
      float w2 = (Sl[sf].tlm[mf].nl+1)*Lsz;
      float w = max(w1,w2);
      pg.strokeWeight(w);
      xa = Sl[si].tlm[mi].x;
      ya = Sl[si].tlm[mi].y;
      xr = xa + cpi.x;
      yr = ya + cpi.y;
      xb = Sl[sf].tlm[mf].x;
      yb = Sl[sf].tlm[mf].y;
      xs = xb + cpf.x;
      ys = yb + cpf.y;
      pg.strokeWeight(w);
      pg.bezier(xa,ya,xr,yr,xs,ys,xb,yb);
    }
    
    pg.popStyle();
  }
    
  void renderPathOld(PGraphics pg)
  {
    float vx;
    float vy;
    float w;
    float xa;
    float ya;
    float xb;
    float yb;
    float xs;
    float ys;
    float xr;
    float yr;
    float ext;
    
    if ( (del == true) || (sf < 0) || (mf > 2) || (si < 0) || (mi > 2) )
      return;
      
    pg.pushStyle();
    pg.noFill();

    vx = -Sl[si].uy;
    vy = Sl[si].ux;
    w = (Sl[si].tlm[mi].nl+1)*Lsz;
    pg.strokeWeight(w);
    pg.stroke(130,130,130);
    if ( Sl[si].type == 1 )  // Pure entry
      ext = 50;
    else
      ext = 0;  // 10 ???
    // Entry acces lane
    // xb = (Sl[si].c[0].x + Sl[si].c[1].x)/2;
    // yb = (Sl[si].c[0].y + Sl[si].c[1].y)/2;
    xb = Sl[si].tlm[mi].x;
    yb = Sl[si].tlm[mi].y;
    xa = xb - vx*ext;
    ya = yb - vy*ext;
    pg.line(xa,ya,xb,yb);

    // Movement path
    xa = xb;
    ya = yb;
    xr = xa + cpi.x;
    yr = ya + cpi.y;

    w = (Sl[si].tlm[mi].nl+Sl[sf].tlm[mf].nl+2)*Lsz/2;
    //xb = (Sl[sf].c[0].x + Sl[sf].c[1].x)/2;
    //yb = (Sl[sf].c[0].y + Sl[sf].c[1].y)/2;
    xb = Sl[sf].tlm[mf].x;
    yb = Sl[sf].tlm[mf].y;
    xs = xb + cpf.x;
    ys = yb + cpf.y;
    pg.strokeWeight(w);
    pg.stroke(130,130,130);
    pg.bezier(xa,ya,xr,yr,xs,ys,xb,yb);
    if ( Sl[sf].type == 2 )  // Pure exit
    {
      float gp = Sl[sf].gap();
      ext = 50 + gp;
    }
    else
    {
      ext = 0;  // 10 ???
    }
    //xa = (Sl[sf].c[0].x + Sl[sf].c[1].x)/2;
    //ya = (Sl[sf].c[0].y + Sl[sf].c[1].y)/2;
    xa = xb;
    ya = yb;
    vx = -Sl[sf].uy;
    vy = Sl[sf].ux;
    xb = xa + vx*ext;
    yb = ya + vy*ext;
    pg.line(xa,ya,xb,yb);

    pg.popStyle();
  }
    
  // Render road markers !!!!
  void renderMarker()
  {
    float vx;
    float vy;
    float xs;
    float ys;
    float xr;
    float yr;
    
    if ( del == true )
      return;
      
    pushStyle();
    // Determines crossing point
/*
    float di = Sl[si].crossDistance(sf);
    float df = Sl[sf].crossDistance(si);
    if ( (di < 0) || (df < 0) )
    {
      float d = Sl[sf].distance(si);
      di = d/2 + 10;
      df = d/2 + 10;
    }
*/
    vx = -Sl[si].uy;
    vy = Sl[si].ux;
    xs = Sl[si].c[0].x - vx*6;
    ys = Sl[si].c[0].y - vy*6;
    xr = Sl[si].c[1].x - vx*6;
    yr = Sl[si].c[1].y - vy*6;
    stroke(250,250,0);
    strokeWeight(4);
    line(xs,ys,xr,yr);
/*
    for ( int i=0 ; i<=Sl[si].nl ; i++ )
    {
      xr = xs - vx*500;
      yr = ys - vy*500;
      if ( i < Sl[si].nl )
        strokeWeight(1);
      else
        strokeWeight(3);
      line(xs,ys,xr,yr);
      xs += Lsz*Sl[si].ux;
      ys += Lsz*Sl[si].uy;
    }

    vx = -Sl[sf].uy;
    vy = Sl[sf].ux;
    xs = Sl[sf].c[0].x - vx*6;
    ys = Sl[sf].c[0].y - vy*6;
    xr = Sl[sf].c[1].x - vx*6;
    yr = Sl[sf].c[1].y - vy*6;
    strokeWeight(4);
    line(xs,ys,xr,yr);

    for ( int i=0 ; i<=Sl[sf].nl ; i++ )
    {
      xr = xs - vx*500;
      yr = ys - vy*500;
      if ( i < Sl[sf].nl )
        strokeWeight(1);
      else
        strokeWeight(3);
      line(xs,ys,xr,yr);
      xs += Lsz*Sl[sf].ux;
      ys += Lsz*Sl[sf].uy;
    }
*/
    pushStyle();
  }
  
  // Render Net !!!!
  void renderNet()
  {
    float vx;
    float vy;
    float xa;
    float ya;
    float xb;
    float yb;
    
    if ( (del == true) || (sf < 0) )
      return;
      
    pushStyle();
    // Determines crossing point
    float di = Sl[si].crossDistance(sf);
    float df = Sl[sf].crossDistance(si);
    vx = -Sl[si].uy;
    vy = Sl[si].ux;
    strokeWeight(2);
    stroke(255,255,0);
    xa = (Sl[si].c[0].x + Sl[si].c[1].x)/2;
    ya = (Sl[si].c[0].y + Sl[si].c[1].y)/2;
    if ( (di > 0) && (df > 0) )
    {
      xb = xa + vx*di;
      yb = ya + vy*di;
    }
    else
    {
      xb = (Sl[sf].c[0].x + Sl[sf].c[1].x)/2;
      yb = (Sl[sf].c[0].y + Sl[sf].c[1].y)/2;
      df = 0;
    }
    line(xa,ya,xb,yb);
    noStroke();
    fill(255,255,0);
    ellipse(xa,ya,3,3);
    ellipse(xb,yb,3,3);

    if ( df > 0 )
    {
      vx = Sl[sf].uy;
      vy = -Sl[sf].ux;
      strokeWeight(2);
      stroke(255,255,0);
      xa = (Sl[sf].c[0].x + Sl[sf].c[1].x)/2;
      ya = (Sl[sf].c[0].y + Sl[sf].c[1].y)/2;
      xb = xa + vx*df;
      yb = ya + vy*df;
      line(xa,ya,xb,yb);
      noStroke();
      fill(255,255,0);
      ellipse(xa,ya,3,3);
      ellipse(xb,yb,3,3);
    }

    pushStyle();
  }
  
  // Draw movement
  void display(color c)
  {
    float x0, y0;
    float x1, y1;
    float vx, vy;
    
    if ( del == false )
    {
      pushStyle();
      // Line from traffic light movement symbol
      if ( mi < 3 )
      {
        x0 = Sl[si].tlm[mi].x;  // xo
        y0 = Sl[si].tlm[mi].y;
      }
      else
      {
        x0 = Sl[si].acp[mi-3].x;
        y0 = Sl[si].acp[mi-3].y;
      }
      if ( sf >= 0 )
      {
        // If stop line known
        if ( mf < 3 )
        {
          x1 = Sl[sf].tlm[mf].x;
          y1 = Sl[sf].tlm[mf].y;
        }
        else
        {
          x1 = Sl[sf].acp[mf-3].x;
          y1 = Sl[sf].acp[mf-3].y;
        }
        stroke(c);
      }
      else
      {
        // While dragging
        x1 = xf;
        y1 = yf;
        stroke(250,50,50);
      }
      
      strokeWeight(4);
      noFill();
      float xr = x0 + cpi.x;
      float yr = y0 + cpi.y;
      float xs = x1 + cpf.x;
      float ys = y1 + cpf.y;
      bezier(x0,y0,xr,yr,xs,ys,x1,y1);
      
      // Midpoint handler !!!
      if ( sf >= 0 )
      {
        float r = 11;
        noStroke();
        fill(c);
        ellipse(cpm.x,cpm.y,r,r);
        fill(50);
        if ( sel == true )
        {
          stroke(0,0,250);
          strokeWeight(3);
          noFill();
          ellipse(cpm.x,cpm.y,r+3,r+3);
          
          if ( mf < 3 )
          {
            // Draw control points handlers
            strokeWeight(1);
            line(x0,y0,xr,yr);
            line(x1,y1,xs,ys);
            ellipse(xr,yr,5,5);
            ellipse(xs,ys,5,5);
          }
        }
      }
      
      popStyle();
    }
  }
}

// Phase movement details (type: red, green or orange)
class Phmov
{
  int im;    // Movement index
  int type;  // 0:Red, 1:Green, 2:Orange
  
  Phmov(int m, int t)
  {
    im = m;
    type = t;
  }
  
  void setMov(int m)
  {
    im = m;
  }

  void setType(int t)
  {
    type = t;
  }
  
  color col()
  {
    color c;
    
    switch ( int(type) )
    {
      case 0:  // Red
        c = color(250,0,0);
        break;

      case 1:  // Green
        c = color(0,250,50);
        break;

      case 2:  // Orange
        c = color(250,150,0);
        break;
      
      default:
        c = color(0,250,50);
        break;
    }
    
    return(c);
  }
}

// Phase class includes the phase movements
class Phase
{
  int pt;  // Phase duration
  ArrayList<Phmov> pmv;  // Phase movements
  
  Phase(int t)
  {
    pt = t;
    pmv = new ArrayList<Phmov>();
  }
  
  void reset(int t)
  {
    pt = t;
    pmv.clear();
    //for ( int i=0 ; i<pmv.size() ; i++ )
    //{
    //  phm = pmv.get(i);
    //  phm.reset();
    //}
  }
  
  // Search for a phase movement by movement id
  int hasMov(int im)
  {
    Phmov phm;
    
    for ( int i=0 ; i<pmv.size() ; i++ )
    {
      phm = pmv.get(i);
      if ( phm.im == im )
        return(i);
    }
    
    return(-1);
  }
  
  // Returns phase movement type
  int movType(int im)
  {
    int i = hasMov(im);
    if ( i >= 0 )
    {
      Phmov phm = pmv.get(i);
      if ( phm != null )
        return(phm.type);
    }
    
    return(0);
  }
  
  // Sets phase movement type
  void setType(int im, int t)
  {
    int i = hasMov(im);
    if ( i >= 0 )
    {
      Phmov phm = pmv.get(i);
      if ( phm != null )
        phm.type = t;
    }
  }
  
  // Adds movement to phase including type
  boolean addMov(int im, int t)
  {
    if ( hasMov(im) < 0 )
    {
      Phmov pm = new Phmov(im,t);
      pmv.add(pm);

      return(true);
    }
    
    return(false);
  }
  
  // Remove movement from phase (ArrayList version)
  boolean removeMov(int im)
  {
    int i = hasMov(im);
    if ( i >= 0 )
    {
      pmv.remove(i);
      return(true);
    }
    
    return(false);
  }
  
  // Checks existence of a movement in the phase by reference (sl|mv)
  int hasMovRef(int mr)
  {
    Phmov pm;
    int im;
    int r;
    
    for ( int i=0 ; i<pmv.size() ; i++ )
    {
      pm = pmv.get(i);
      im = pm.im;
      r = MRef(Mv[im].si,Mv[im].mi);
      if ( mr == r )
        return(im);
    }
    
    return(-1);
  }
  
  // Checks if mouse over phase movement
  int overMov(float x, float y)
  {
    Phmov phm;

    for ( int i=0 ; i<pmv.size() ; i++ )
    {
      phm = pmv.get(i);
      int im = phm.im;
      if ( Mv[im].over(x,y) == true )
      {
        return(im);
      }
    }
    
    return(-1);
  }
  
  // Render phase movements
  void renderMov(float sz)
  {
    for ( int i=0 ; i<Maxsl ; i++ )
    {
      if ( Sl[i].del == false )
      {
        for ( int j=0 ; j<Sl[i].nm ; j++ )
        {
          //int t = Sl[i].tlm[j].type;
          int im = hasMovRef(MRef(i,j));
          if ( im >= 0 )
          {
            int t = movType(im);
            Sl[i].renderMov(j,t,sz);
          }
          else
            Sl[i].renderMov(j,0,sz);
        }
      }
    }
  }

  // Display phase in configuration mode
  void display()
  {
    color csel = 0;
    int msel = -1;
    for ( int i=0 ; i<pmv.size() ; i++ )
    {
      Phmov phm = pmv.get(i);
      int m = phm.im;
      color c = phm.col();
      if ( Mv[m].sel == false )
      {
        //println("Draw Mv: "+m);
        // Draw movement line
        Mv[m].display(c);
      }
      else
      {
        csel = c;
        msel = m;
      }
    }
    
    if ( msel >= 0 )
      Mv[msel].display(csel);
  }
}  
  
// Phases structure
class JStruct
{
  int Maxph;   // Max number of phases
  int nph;     // Number of phases defined
  Phase[] Ph;  // Phases data
  int cycl;    // Total cycle time in msec
  int sel;     // Selected phase
  
  int x;       // Phases control graph coordinates and size
  int y;
  int w;
  int h;
  float[] px;  // Phases graph division X coordinate
  
  int psel;    // Selected phase division for dragging
  float xsel;
  int tsel;
  int tsel1;
  
  int t;     // Cycle current time
  int pc;    // Current phase
  
  
  JStruct()
  {
    Maxph = 9;  // !!!
    Ph = new Phase[Maxph];
    // Init phases array
    for ( int i=0 ; i<Maxph ; i++ )
      Ph[i] = new Phase(30);  // Default time in secs!!!

    px = new float[Maxph];
    reset();
  }
  
  // Reset all phases
  void reset()
  {
    nph = 0;
    cycl = 0;
    sel = -1;
    psel = -1;
    pc = 0;
    t = 0;

    for ( int i=0 ; i<Maxph ; i++ )
      Ph[i].reset(30);  // Default time in secs!!!
  }
  
  // Adds new phase
  int newPhase(int s)
  {
    if ( nph < Maxph  )
    {
      nph++;
      Ph[nph-1].pt = 1000*s;
      
      updateCycle();
      
      return(nph-1);
    }
    
    return(-1);
  }
  
  // Removes phase
  int removePhase()
  {
    if ( sel < nph  )
    {
      Ph[sel].reset(0);  // Default time in secs!!!
      for ( int i=sel ; i<nph-1 ; i++ )
        Ph[i] = Ph[i+1];
      
      if ( nph > 1 )
        nph--;

      updateCycle();
    }
    
    return(nph);
  }

  // Creates a control component
  void setControl(int x, int y, int w, int h)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;

    updateControl();
  }
  
  // Update control
  void updateControl()
  {
    if ( cycl > 0 )
    {
      float xprv = 0;
      for ( int i=0 ; i<nph ; i++ )
      {
        px[i] = xprv + Ph[i].pt*(w-2*h)/cycl;
        xprv = px[i];
      }
    }
  }
  
    // Update cycl
  void updateCycle()
  {
    cycl = 0;
    for ( int i=0 ; i<nph ; i++ )
      cycl += int(Ph[i].pt);  // $$$
    
    updateControl();
  }
  
  // Check mouse over phase division
  int overPD(float xm, float ym)
  {
    if ( (ym < y) || (ym > y+h) )
      return(-1);
    
    float spl;
    for ( int i=0 ; i<nph-1 ; i++ )
    {
      spl = px[i];
      if ( (xm > spl-5) && (xm < spl+5) )
        return(i);
    }
    
    return(-1);
  }
  
  // Check mouse over cycle adjusting buttons
  int overCB(float xm, float ym)
  {
    if ( dist(xm,ym,(w-3*h/2),(y+h/2)) < h/2 )
      return(-1);

    if ( dist(xm,ym,(w-h/2),(y+h/2)) < h/2 )
      return(1);

    return(0);
  }
  
  // Check mouse over phase
  int over(float xm, float ym)
  {
    if ( (ym < y) || (ym > y+h) )
      return(-1);
    
    float spl;
    float splbk = 0;
    for ( int i=0 ; i<nph ; i++ )
    {
      spl = px[i];
      if ( (xm > splbk) && (xm < spl) )
        return(i);
      
      splbk = spl;
    }
    
    return(-1);
  }
  
  // Change cycle duration in seconds (last pahse)
  void chgCycle(int incsec)
  {
    Ph[nph-1].pt = int(Ph[nph-1].pt) + 1000*incsec;  // $$$
    if ( Ph[nph-1].pt < 5000 )
      Ph[nph-1].pt = 5000;
      
    updateCycle();
    
    init();
  }
  
  // Select division to drag
  void dragSel(int p)
  {
    psel = p;
    xsel = px[p];
    tsel = int(Ph[p].pt);  // $$$
    tsel1 = int(Ph[p+1].pt);
  }
  
  // Drag selected division
  void dragMov(float xm, float ym)
  {
    float splmin;
    float splmax;
    
    if ( psel >= 0 )
    {
      if ( psel == 0 )
        splmin = 0;
      else
        splmin = px[psel-1];

      if ( psel < nph-1 )
      {
        splmax = px[psel+1];
        int inc = round((xm - xsel)*cycl/(1000*(w-2*h)))*1000;
        //if ( (xm > splmin+20) && (xm < splmax-20) )
        if ( (tsel + inc >= 5000) && (tsel1 - inc >= 5000) )
        {
          //int inc = round((xm - xsel)*cycl/(w-2*h));
          px[psel] = xm;
          Ph[psel].pt = tsel + inc;
          Ph[psel+1].pt = tsel1 - inc;
          
          init();
        }
      }
    }
  }
  
  // Unselect division to drag
  void dragRel()
  {
    psel = -1;
  }
  
  // Display phases time bar
  void display()
  {
    pushStyle();
    fill(250);
    textSize(h-4);
    textAlign(CENTER,CENTER);
    rect(x,y,w,h);
    stroke(30);
    //line(x,y,x,y+h);
    ellipse((w-3*h/2),(y+h/2),h/2.5,h/2.5);
    ellipse((w-h/2),(y+h/2),h/2.5,h/2.5);
    fill(30);
    text("-",(w-3*h/2),(y+h/2-2));
    text("+",(w-h/2),(y+h/2-2));
    float spl = 0;
    float splbk = 0;
    for ( int i=0 ; i<nph ; i++ )
    {
      spl = px[i];
      line(spl,y,spl,y+h);
      if ( (sel == i) && (t == 0) )
      {
        fill(120);
        rect(splbk,y,spl-splbk,h);
        fill(255);
      }
      else
      {
        fill(30);
      }
      String s = str(int(Ph[i].pt/1000)) + " s";
      text(s,(splbk+spl)/2,y+h/2-2);
        
      splbk = spl;
    }
    
    if ( t > 0 )
    {
      // Mark cycle time bar
      float xm = (w - 2*h)*t/cycl;
      fill(255,0,0,150);
      rect(x,y,xm,h);
    }
    
    popStyle();
  }
  
  // Start timing
  void init()
  {
    t = 0;
    pc = -1;
    
    Simd.init();
  }
  
  // Run timing structure
  int run(int tl)
  {
    if ( cycl > 0 )
    {
      int np = 0;
      t = tl % cycl;
      int acut = Ph[0].pt;
      for ( int i=1 ; i<nph ; i++ )
      {
        // println("T: "+t+"  Pti: "+acut);
        if ( t < acut )
          break;
  
        acut += Ph[i].pt;
        np++;
      }
      
      if ( np != pc )
      {
        pc = np;
        return(np);
      }
    }
    
    return(-1);
  }
}


// Reset stop lines
void ResetSl()
{
  for ( int i=0 ; i<Maxsl ; i++ )
  {
    Sl[i].del = true;
    Sl[i].selected = false;
    Sl[i].invalid = true;
    Sl[i].dragmode = 0;
    Sl[i].nl = 0;
    Sl[i].type = 0;

    for ( int j=0 ; j<Maxln ; j++ )
      Sl[i].ln[j].reset();

    Sl[i].nm = 0;
    for ( int j=0 ; j<3 ; j++ )
    {
      Sl[i].tlm[j].reset();
      //acp[i] = new AccessPoint();
    }
  }

  SelSl = -1;  // Stop Line selected
  Lsz = 0;   // Default lane size (initially undefined)
  Nsl = 0;
}

// Unselect all stop lines
void UnselectAllSl()
{
    for ( int i=0 ; i<Maxsl ; i++ )
      Sl[i].unSelect();
}    


// Unselect all loops
void UnselectAllLoops()
{
    for ( int i=0 ; i<Maxsl ; i++ )
      Sl[i].unselectLoops();
}    

// Delete selected loop, if any
void DeleteSelLoops()
{
    for ( int i=0 ; i<Maxsl ; i++ )
      Sl[i].deleteLoop();
}    

// Allocate new stop line
int AllocateSl(float x, float y)
{
  for ( int i=0 ; i<Maxsl ; i++ )
  {
    if ( Sl[i].del == true )
    {
      Sl[i].del = false;
      if ( Nsl == 0 )
        Sl[i].main = true;
      else
        Sl[i].main = false;
      for ( int j=0 ; j<2 ; j++ )
        Sl[i].setVertex(j,x,y);
      //Sl[i].csave = Sl[i].c;
      Sl[i].selected = true;
      Sl[i].invalid = true;
      Sl[i].type = 0;
      Sl[i].nl = 0;
      Sl[i].nm = 0;
      Sl[i].dragVertex(1,x,y);  // Resize
      Nsl++;
      Changes = true;
      return(i);
    }
  }
  
  return(-1);
}

// Deallocate stop line
void DeallocateSl(int i)
{
  if ( i < Maxsl )
  {
    Sl[i].del = true;
    SelSl = -1;
    Nsl--;
    Changes = true;
    
    // Deallocate affected movements
    for ( int j=0 ; j<Maxmv ; j++ )
    {
      if ( Mv[j].del == false )
      {
        if ( Mv[j].hasValue(i) == true )
          DeallocateMv(j);
      }
    }
  }
}

void UpdateAllSl()
{
  // If lane size changes then update all stop lines
  for ( int i=0 ; i<Maxsl ; i++ )
    if ( Sl[i].del == false )
      Sl[i].updateSize();
}

// Reset movements
void ResetMv()
{
  for ( int i=0 ; i<Maxmv ; i++ )
    Mv[i].reset();
}

// Allocate new movement
int AllocateMv(int smi)
{
  for ( int i=0 ; i<Maxmv ; i++ )
  {
    if ( Mv[i].del == true )
    {
      Mv[i].del = false;
      Mv[i].sel = false;
      int si = MRefSl(smi);
      Mv[i].si = si;
      int mi = MRefMv(smi);
      Mv[i].mi = mi;
      Mv[i].sf = -1;
      Mv[i].mf = -1;
      if ( mi < 3 )
      {
        Mv[i].xf = Sl[si].tlm[mi].x;  // xo
        Mv[i].yf = Sl[si].tlm[mi].y;
      }
      else
      {
        Mv[i].xf = Sl[si].acp[mi-3].x;  // xo
        Mv[i].yf = Sl[si].acp[mi-3].y;
      }
      Mv[i].cpi.set(0,0);
      Mv[i].cpf.set(0,0);
      Nmv++;        
      Changes = true;
      return(i);
    }
  }
  
  return(-1);
}

// Deallocate stop line
void DeallocateMv(int im)
{
  if ( im < Maxmv )
  {
    Mv[im].del = true;
    SelMv = -1;
    Nmv--;
    Changes = true;

    // Deallocate affected phases
    for ( int k=0 ; k<JS.nph ; k++ )
    {
      if ( JS.Ph[k].hasMov(im) >= 0 )
        JS.Ph[k].removeMov(im);
    }
  }
}

// Unselect movement
void UnselectMovement()
{
  if ( SelMv >= 0 )
  {
    Mv[SelMv].sel = false;
    Mv[SelMv].unselControlPoint();
    SelMv = -1;
  }
}

// Select movement
void SelectMovement(int im)
{
  if ( SelMv >= 0 )
    UnselectMovement();

  SelMv = im;
  Mv[im].sel = true;
  Mv[im].unselControlPoint();
}

// Checks stop line movements to avoid inconsistencies
boolean CheckMovements(int sl, int m)
{
  for ( int i=0 ; i<Maxmv ; i++ )
  {
    if ( Mv[i].del == false )
    {
      if ( (Mv[i].si == sl) && (Mv[i].mi == m) )
        return(true);
    }
  }

  return(false);
}

// Update movements data
void UpdateMovements()
{
  for ( int i=0 ; i<Maxmv ; i++ )
  {
    if ( Mv[i].del == false )
      Mv[i].update();
  }
}

// Seek movement
// Checks for the existence of a movement
int SeekMovement(int si, int mi, int sf, int mf)
{
  for ( int i=0 ; i<Maxmv ; i++ )
  {
    if ( Mv[i].del == false )
    {
      if ( (Mv[i].si == si) && (Mv[i].mi == mi) && (Mv[i].sf == sf) && (Mv[i].mf == mf) )
        return(i);
    }
  }

  return(-1);
}

// Render all movements
void RenderMovements()
{
  for ( int i=0 ; i<Maxmv ; i++ )
    Mv[i].renderPath(g);
  /*
  for ( int i=0 ; i<Maxmv ; i++ )
    Mv[i].renderMarker();
  */
}

void RenderMovementsPG()
{
  pg.beginDraw();
  pg.rectMode(CORNERS);
  pg.strokeCap(SQUARE);
  //pg.clear(); $$$
  pg.background(256);

  for ( int i=0 ; i<Maxmv ; i++ )
    Mv[i].renderPath(pg);

  pg.endDraw();
}

boolean MovementUsed(int im)
{
  for ( int i=0 ; i<JS.nph ; i++ )
  {
    if ( JS.Ph[i].hasMov(im) >= 0 )
      return(true);
  }
  
  return(false);
}

// Render junction network
void RenderNetwork()
{
  for ( int i=0 ; i<Maxmv ; i++ )
    Mv[i].renderNet();
}

// Save junction configuration
void SaveGraph(String file)
{
  XML xml = new XML(file);
  
  // Stop lines data
  for ( int i=0 ; i<Maxsl ; i++ )
  {
    if ( Sl[i].del == false )
    {
      XML child = xml.addChild("stopline");
      child.setInt("Id",i);
      child.setInt("Nl",Sl[i].nl);
      child.setFloat("Xi",Sl[i].c[0].x);
      child.setFloat("Yi",Sl[i].c[0].y);
      child.setFloat("Xf",Sl[i].c[1].x);
      child.setFloat("Yf",Sl[i].c[1].y);
      for ( int j=0 ; j<Sl[i].nl ; j++ )
      {
        XML child2 = child.addChild("Mov");
        child2.setInt("Id",j);
        child2.setInt("Type",Sl[i].ln[j].type);
      }
      for ( int j=0 ; j<Sl[i].nm ; j++ )
      {
        for ( int k=0 ; k<Sl[i].tlm[j].l.nl ; k++ )
        {
          XML child2 = child.addChild("Loop");
          child2.setInt("Lane",j);
          child2.setFloat("X",Sl[i].tlm[j].l.lp[k].x);
          child2.setFloat("Y",Sl[i].tlm[j].l.lp[k].y);
          child2.setFloat("Ux",Sl[i].tlm[j].l.lp[k].ux);
          child2.setFloat("Uy",Sl[i].tlm[j].l.lp[k].uy);
          child2.setFloat("Sz",Sl[i].tlm[j].l.lp[k].l);
        }
      }
    }
  }
  
  // Movements data
  for ( int i=0 ; i<Maxmv ; i++ )
  {
    if ( Mv[i].del == false )
    {
      XML child = xml.addChild("movement");
      child.setInt("Id",i);
      child.setInt("startMov",Mv[i].mi);
      child.setInt("startSL",Mv[i].si);
      child.setInt("endMov",Mv[i].mf);
      child.setInt("endSL",Mv[i].sf);
      child.setFloat("startCtrlpX",Mv[i].cpi.x);
      child.setFloat("startCtrlpY",Mv[i].cpi.y);
      child.setFloat("endCtrlpX",Mv[i].cpf.x);
      child.setFloat("endCtrlpY",Mv[i].cpf.y);
    }
  }
  
  // Phases data
  for ( int i=0 ; i<JS.nph ; i++ )
  {
    int nm = JS.Ph[i].pmv.size();
    if ( nm > 0 )
    {
      XML child = xml.addChild("phase");
      child.setInt("IdPH",i);
      child.setInt("Time",JS.Ph[i].pt);
      //child.setInt("Nmov",nm);
      for ( int j=0 ; j<nm ; j++ )
      {
        XML child2 = child.addChild("Mov");
        Phmov pm = JS.Ph[i].pmv.get(j);
        child2.setInt("Idm",pm.im);
        child2.setInt("Type",pm.type);
      }
    }
  }

  if ( saveXML(xml,file) )
    Changes = false;
}

// Load junction configuration
void LoadGraph(String file)
{
  XML xmlr = null;
  int nl = 0;
  int id;
  Vertex ci = new Vertex(0,0);
  Vertex cf = new Vertex(0,0);
  
  // $$$
  
  try
  {
    xmlr = loadXML(file);
  }
  catch (Exception e)
  {
    e.printStackTrace();
    xmlr = null;
  }
  
  // xmlr = loadXML(file);
  
  if ( xmlr != null )
  {
    // Stop lines data
    Nsl = 0;
    XML[] child = xmlr.getChildren("stopline");
    for ( int i=0 ; i<child.length ; i++ )
    {
      id = child[i].getInt("Id");
      nl = child[i].getInt("Nl");
      ci.x = child[i].getFloat("Xi");
      ci.y = child[i].getFloat("Yi");
      cf.x = child[i].getFloat("Xf");
      cf.y = child[i].getFloat("Yf");
      XML[] childslm = child[i].getChildren("Mov");
      for ( int j=0 ; j<nl ; j++ )
      {
        int t;
        int l;
        if ( childslm.length > j )
        {
          l = childslm[j].getInt("Id");
          t = childslm[j].getInt("Type");
        }
        else
        {
          l = 0;
          t = FRONT_MOV;
        }
        Sl[id].ln[l].type = t;
      }
      //Sl[id] = new StopLine(ci,cf);
      Sl[id].del = false;
      Sl[id].invalid = false;
      Sl[id].nl = nl;
      Sl[id].setVertex(0,ci.x,ci.y);
      Sl[id].setVertex(1,cf.x,cf.y);
      Sl[id].saveCoords();
      Sl[id].dragmode = 0;
      if ( Nsl == 0 )
      {
        Sl[id].main = true;
        Lsz = Sl[id].U/Sl[id].nl;
      }
      else
        Sl[id].main = false;
        
      //Sl[id].updateLanes();
      Sl[id].update();
      // Stop line loops
      XML[] childslp = child[i].getChildren("Loop");
      for ( int j=0 ; j<childslp.length ; j++ )
      {
        int l = childslp[j].getInt("Lane");
        float x = childslp[j].getFloat("X");
        float y = childslp[j].getFloat("Y");
        float ux = childslp[j].getFloat("Ux");
        float uy = childslp[j].getFloat("Uy");
        float sz = childslp[j].getFloat("Sz");
        Sl[id].tlm[l].addLoop(x,y,ux,uy,sz);
      }
      
      Nsl++;
    }
    
    // Movements data
    Nmv = 0;
    XML[] childm = xmlr.getChildren("movement");
    for ( int i=0 ; i<childm.length ; i++ )
    {
      id = childm[i].getInt("Id");
      int mi = childm[i].getInt("startMov");
      int sli = childm[i].getInt("startSL");
      int mf = childm[i].getInt("endMov");
      int slf = childm[i].getInt("endSL");
      float xr = childm[i].getFloat("startCtrlpX");
      float yr = childm[i].getFloat("startCtrlpY");
      float xs = childm[i].getFloat("endCtrlpX");
      float ys = childm[i].getFloat("endCtrlpY");
      //Mv[id] = new Movement(sli,slf);
      if ( SeekMovement(sli,mi,slf,mf) < 0 )
      {
        Mv[id].si = sli;
        Mv[id].sf = slf;
        Mv[id].mi = mi;
        Mv[id].mf = mf;
        if ( (xr != 0) && (yr != 0) && (xs != 0) && (ys != 0) )
          Mv[id].setControlPoints(xr,yr,xs,ys);
        else
          Mv[id].initControlPoints();  // !!!
        //Mv[id].type = Sl[sli].tlm[mi].type;
        Mv[id].del = false;
        if ( mf < 3 )
          Sl[sli].setType(0x01);
        Sl[slf].setType(0x02);
        Nmv++;
      }
    }

    // Phases data
    XML[] childp = xmlr.getChildren("phase");
    JS.nph = childp.length;
    for ( int i=0 ; i<JS.nph ; i++ )
    {
      int idph = childp[i].getInt("IdPH");  // !!!
      int t = childp[i].getInt("Time");
      if ( t <= 0 )
        JS.Ph[i].pt = 30000;  // Default msec !!!
      else
        JS.Ph[i].pt = t;
      XML[] childpm = childp[i].getChildren("Mov");
      for ( int j=0 ; j<childpm.length ; j++ )
      {
        int m = childpm[j].getInt("Idm");
        int type = childpm[j].getInt("Type");
        JS.Ph[i].addMov(m,type);
      }
    }
    JS.updateCycle();
    
    Changes = false;
  }
}




// Mouse pressed in edit mode 0 (stop line)
void MousePressedMode0()
{
  int item;
  
  if ( SelSl >= 0 )  // A stop line selected
  {
    // Is over a Vertex ?
    item = Sl[SelSl].overVertex(mouseX,mouseY);
    if ( item >= 0 )
    {
      Sl[SelSl].dragVertex(item,mouseX,mouseY);
      cursor(MOVE);
      return;
    }

    // Is over an edge ?
    if ( Sl[SelSl].overEdge(mouseX,mouseY) == true )
    {
      Sl[SelSl].dragEdge(mouseX,mouseY);
      cursor(MOVE);
      return;
    }
    
    // Is over a lane symbol?
    item = Sl[SelSl].overLane(mouseX,mouseY);
    if ( item >= 0 )
    {
      cursor(HAND);
      return;
    }

    // Click outside selected stop line
    UnselectAllSl();
    SelSl = -1;
    cursor(ARROW);
  }

  // Over another stop line?
  for ( int i=0 ; i<Maxsl ; i++ )
  {
    if ( Sl[i].overEdge(mouseX,mouseY) == true )
    {
      Sl[i].Select();
      Sl[i].dragEdge(mouseX,mouseY);
      SelSl = i;
      cursor(MOVE);
      redraw();
      return;
    }
    
    if ( Sl[i].overLane(mouseX,mouseY) >= 0 )
    {
      Sl[i].Select();
      SelSl = i;
      cursor(HAND);
      redraw();
      return;
    }
  }
   
  // Click outside stop line, create new stop line
  if ( (Nsl == 0) || (Lsz != 0) )
  {
    int i = AllocateSl(mouseX,mouseY);
    if ( i >= 0 )
      SelSl = i;
  }

  redraw();
}

// Check if mouse pressed over stop line / traffic light movement
int PressOverSl(float x, float y)
{
  for ( int i=0 ; i<Maxsl ; i++ )
  {
    if ( Sl[i].del == false )
    {
      int m = Sl[i].overTlmv(x,y);
      if ( m >= 0 )
        return(MRef(i,m));
      
      m = Sl[i].overAccess(x,y);
      if ( m >= 0 )
        return(MRef(i,(m+3)));
    }
  }
  
  return(-1);
}

// Mouse pressed actions
void mousePressed()
{
  switch ( int(Mode) )
  {
    case 0: // Edit stop line
      MousePressedMode0();
      break;
    
    case 1: // Configure phase movement
      if ( JS.sel >= 0 )
      {
        // First check if over dragable control point
        if ( SelMv >= 0 )
        {
          int ctlp = Mv[SelMv].overControlPoint(mouseX,mouseY);
          if ( ctlp >= 0 )
          {
            Mv[SelMv].selControlPoint(ctlp);
            DrgMv = -1;
            break;
          }
        }
        // Now, check if over a stop line
        int si = PressOverSl(mouseX,mouseY);
        if ( si >= 0 )
        {
          UnselectMovement();
          //println("Allocate: "+(si>>2)+" , "+(si&0x03));
          DrgMv = AllocateMv(si);
        }
        else
        {
          DrgMv = -1;
        }

        // Control bar
        int pdiv = JS.overPD(mouseX,mouseY);
        if ( pdiv >= 0 )
          JS.dragSel(pdiv);
      }
      break;
      
    case 2:
      int pdiv = JS.overPD(mouseX,mouseY);
      if ( pdiv >= 0 )
        JS.dragSel(pdiv);
      break;
   }
}

// Drag stop line or movement
void mouseDragged()
{
  switch ( int(Mode) )
  {
    case 0: // Edit stop line
      // Any selected?
      if ( SelSl >= 0 )
      {
        float sz = Lsz;
        Sl[SelSl].Drag(mouseX,mouseY);
        if ( sz != Lsz )
          UpdateAllSl();
        redraw();
      }
      break;
    
    case 1: // Drag movement
      if ( JS.sel >= 0 )
      {
        if ( DrgMv >= 0 )
        {
          /*
          if ( sfm >= 0 )
            contextHelp("Drop here to create a new movement to this stop line");
          else
            contextHelp("Drop outside to cancel");
          */
          Mv[DrgMv].drag(mouseX,mouseY);
        }
        else if ( SelMv >= 0 )
        {
          Mv[SelMv].dragControlPoint(mouseX,mouseY);
        }

        // Control bar
        JS.dragMov(mouseX,mouseY);
        redraw();
      }
      break;
      
    case 2:
      JS.dragMov(mouseX,mouseY);
      break;      
  }
}

// Release dragging
void mouseReleased()
{
  switch ( int(Mode) )
  {
    case 0: // Release dragging stop line
      if ( SelSl >= 0 )
      {
        Sl[SelSl].Release();
        if ( Sl[SelSl].del == true )
          SelSl = -1;
        redraw();
      }
      break;
    
    case 1: // Release dragging movement
      if ( JS.sel >= 0 )
      {
        if ( DrgMv >= 0 )
        {
          int sfm = PressOverSl(mouseX,mouseY);
          if ( sfm >= 0 )
          {
            UnselectMovement();
            // Avoid duplicating movements
            int sf = MRefSl(sfm);
            int sm = MRefMv(sfm);
            int m = SeekMovement(Mv[DrgMv].si,Mv[DrgMv].mi,sf,sm);
            println("Release "+sf+" , "+sm+" m: "+m);
            if ( m < 0 )
            {
              // New movement
              if ( Mv[DrgMv].set(sfm) == true )
              {
                SelectMovement(DrgMv);
                println("Phase("+JS.sel+").add("+DrgMv+") Dragmoved");
                JS.Ph[JS.sel].addMov(DrgMv,1);
      
                if ( (BackMode != 0) && (BackMode != 3) )
                  RenderMovementsPG();  // !!!
              }
            }
            else
            {
              // Movement already exist, add to phase
              DeallocateMv(DrgMv);
              SelectMovement(m);
              //println("Phase("+JS.sel+").add("+m+") Existing");
              JS.Ph[JS.sel].addMov(m,1);
            }
          }
          else
          {
            // Released outside valid point, discard movement
            //if ( JS.sel >= 0 )
            //  JS.Ph[JS.sel].remove(SelMv);
            DeallocateMv(DrgMv);
          }
          DrgMv = -1;
        }
        else
        {
          JS.dragRel();
        }
        redraw();
      }
      else if ( SelMv >= 0 )
      {
        Mv[SelMv].dropControlPoint(mouseX,mouseY);
        redraw();
      }
      break;
  }
}

// Mouse move operation
void mouseMoved()
{
  int item;
  
  switch ( int(Mode) )
  {
    case 0: // Move while editing stop line
      if ( SelSl >= 0 )  // Someone selected
      {
        // Is cursor over a Vertex ?
        item = Sl[SelSl].overVertex(mouseX,mouseY);
        if ( item >= 0 )
        {
          if ( SelSl == 0 )
            contextHelp("Drag from the corner to change all lanes size");
          else
            contextHelp("Drag from the corner to increase/reduce number of lanes");
          cursor(MOVE);
          return;
        }
    
        // Is cursor over an edge ?
        if ( Sl[SelSl].overEdge(mouseX,mouseY) == true )
        {
          contextHelp("Drag to move stop line");
          cursor(MOVE);
          return;
        }
        
        // Is cursor over a lane ?
        item = Sl[SelSl].overLane(mouseX,mouseY);
        if ( item >= 0 )
        {
          contextHelp("Click to change movement type (right, front, left)");
          cursor(HAND);
          return;
        }
        
        // Outside selected
        if ( (Nsl == 0) || ( Lsz > 0) )
        {
          if ( SelSl == 0 )
            contextHelp("Press 1..9 to change the number of lanes  |  Click & drag to create a new stop line");
          else
            contextHelp("Click & drag to create a new stop line");
        }
        else
          contextHelp("Press 1..9 to set the stop line number of lanes");
        cursor(ARROW);
      }
      else
      {
        if ( (Nsl == 0) || ( Lsz > 0) )
          contextHelp("Click & drag to create a new stop line");
        else
          contextHelp("Press 1..9 to set the stop line number of lanes");
        
        for ( int i=0 ; i<Maxsl ; i++ )
        {
          if ( Sl[i].overEdge(mouseX,mouseY) == true )
          {
            contextHelp("Click to select stop line");
          }
          else if ( Sl[i].overLane(mouseX,mouseY) >= 0 )
            contextHelp("Click to change movement type (right, front, left)");
        }
      }
      break;
    
    case 1: // Move while editing phase movement
      if ( JS.sel >= 0 )
      {
        int sfm = PressOverSl(mouseX,mouseY);
        if ( sfm < 0 )
        {
          // Outside stop line
          contextHelp("Ph: "+(JS.sel+1)+"  |  Drag & drop from a stop line to create a new movement");
          if ( SelMv >= 0 )
          {
            int ctlp = Mv[SelMv].overControlPoint(mouseX,mouseY);
            if ( ctlp >= 0 )
            {
              contextHelp("Drag the control point to change the movement shape");
            }
            else
            {
              int m = JS.Ph[JS.sel].overMov(mouseX,mouseY);
              if ( m >= 0 )
                contextHelp("Left-click: Unselects movement  |  Righ-click: Changes movement color");
              else
                contextHelp("Press DEL to remove the phase movement");
            }
          }
          else
          {
            if ( JS.sel >= 0 )
            {
              int m = JS.Ph[JS.sel].overMov(mouseX,mouseY);
              if ( m >= 0 )
                contextHelp("Left-click: Selects movement  |  Right-click: Change movement color");
              else
                contextHelp("Phase "+(JS.sel+1)+": Drag & drop from a stop line to create a new movement  |  Select a phase clicking in the time bar");
            }
          }
        }
        else
        {
          contextHelp("Click & drag to create a new movement from this stop line");
        }

        // Over control bar
        if ( JS.overPD(mouseX,mouseY) >= 0 )
        {
          contextHelp("Drag to change phase duration");
          cursor(MOVE);
        }
        else if ( JS.overCB(mouseX,mouseY) != 0 )
        {
          contextHelp("Click to change cycle duration");
          cursor(HAND);
        }
        else if ( JS.over(mouseX,mouseY) >= 0 )
        {
          contextHelp("Click to select phase");
          cursor(HAND);
        }
        else
          cursor(ARROW);
      }
      break;
      
      case 2:
        if ( Simulation == false )
        {
          if ( JS.overPD(mouseX,mouseY) >= 0 )
            cursor(MOVE);
          else if ( JS.overCB(mouseX,mouseY) != 0 )
            cursor(HAND);
          else
            cursor(ARROW);
        }
        break;
  } 
}

// Click to select or change something
void mouseClicked()
{
  switch ( int(Mode) )
  {
    case 0:
      if ( SelSl >= 0 )
      {
        int l = Sl[SelSl].overLane(mouseX,mouseY);
        if ( l >= 0 )
        {
          int m = Sl[SelSl].getTlm(l);
          if ( (mouseButton == LEFT) && (CheckMovements(SelSl,m) == false) )
          {
            if ( Sl[SelSl].chgType(l) == true )
            {
              // Lane type changed
              redraw();
            }
          }
          else
            Warning("Stop line movement type cannot be changed when a phase is configured",3);
        }
      }
      
      // Check click on loops
      // First unselects all loops
      UnselectAllLoops();
      for ( int i=0 ; i<Maxsl ; i++ )
      {
        if ( Sl[i].del == false )
        {
          int ml = Sl[i].overLoop(mouseX,mouseY);
          if ( ml >= 0 )
          {
            int n = ml & 0x03;
            int l = ml >> 2;
            println("tlm: "+n+" Loop: "+l);
            if ( l > 0 )
              Sl[i].tlm[n].l.select(l-1);
            else
              Sl[i].tlm[n].l.add();
          }
        }
      }
      break;
      
    case 1:
      if ( JS.sel >= 0 )
      {
        // On phase movement
        int m = JS.Ph[JS.sel].overMov(mouseX,mouseY);
        if ( m >= 0 )
        {
          if ( mouseButton == LEFT )
          {
            // Left button to select
            if ( Mv[m].sel == false )
            {
              SelectMovement(m);
            }
            else
            {
              UnselectMovement();
            }
          }
          else if ( mouseButton == RIGHT )
          {
            // Right button to change color
            int t = JS.Ph[JS.sel].movType(m);
            if ( t == 1 )  // Green
              t = 2;  // Orange
            else if ( t == 2 )  // Orange
              t = 1;  // Green
            JS.Ph[JS.sel].setType(m,t);
          }
        }
        else
        {
          UnselectMovement();
        }
        if ( SelMv >= 0 )
        {
          int si = Mv[SelMv].si;
          
        }

        // Over control bar
        int cb = JS.overCB(mouseX,mouseY);
        if ( cb != 0 )
          JS.chgCycle(5*cb);
        
        int ph = JS.over(mouseX,mouseY);
        if ( ph >= 0 )
        {
          JS.sel = ph;
          UnselectMovement();
        }

        redraw();
      }
      break;
      
      case 2:
        if ( Mode3D )
          break;
        int cb = JS.overCB(mouseX,mouseY);
        if ( cb != 0 )
        {
          JS.chgCycle(5*cb);
          redraw();
        }
        /* Bug clicking outside a vehicle !!!
        Vehicle v = JSys.overVehicle(mouseX,mouseY);
        if ( v != null )
        {
          println("*********************");
          println("Vehicle: "+v.id);
          println("Offset: "+v.loc.accofs);
          if ( v.bv != null )
          {
            println("Blocking V: "+v.bvid);
            println("Blocking type: "+v.bvtype);
            println("Blocking dist: "+v.bvdist);
          }
          println("Path: "+hex(v.curp.id));
          println("Crossings: ");
          for ( CrossPath cr: v.curp.crossp )
            println("    Ofsi: "+cr.cs.ofsi+" -> "+cr.cs.ofsf);          
        }
        */
        break;      
  }
}

// 

// Check keys pressed
void keyPressed()
{
  KeyPressed(int(key));
}

void KeyPressed(int k)
{
  if ( k == DELETE )  // $$$
  {
    switch ( int(Mode) )
    {
      case 0:
        if ( SelSl >= 0 )
        {
          // La principal no se puede borrar
          if ( SelSl != 0 )
          {
            DeallocateSl(SelSl);
            if ( (BackMode != 0) && (BackMode != 3) )
              RenderMovementsPG();  // !!!
            cursor(ARROW);
          }
          else
            Warning("Reference stop line cannot be removed",3);
        }
        DeleteSelLoops();
        redraw();
        break;
        
      case 1:
        if ( SelMv >= 0 )
        {
          // Si es la 'main' se borrarán todas
          if ( JS.sel >= 0 )
            JS.Ph[JS.sel].removeMov(SelMv);
          if ( MovementUsed(SelMv) == false )
            DeallocateMv(SelMv);
          if ( (BackMode != 0) && (BackMode != 3) )
            RenderMovementsPG();  // !!!
          UnselectMovement();
          redraw();
        }
        break;
    }
    
    return;
  }
  
  if ( (k == ESC) || (k == 'X') || (k == 'x') )
  {
    if ( Mode > 0 )
    {
      if ( Mode == 2 )
      {
        if ( Mode3D )
        {
          Mode3D = false;
          key = 0;
          redraw();
          return;
        }
      }
      if ( Mode == 1 )
      {
        int np = JS.nph - 1;
        if ( np >= 0 )
        {
          if ( JS.Ph[np].pmv.size() == 0 )
          {
            JS.nph--;
            JS.updateCycle();
          }
        }            
        RenderMovementsPG();
      }
      Mode = 0;
      Scale = 1;
      UnselectMovement();
      JS.sel = -1;
      SelSl = -1;
      Simulation = false;
      Mode3D = false;
      Paused = true;
      BirdEye = false;
      JS.init();
      contextHelp("");
      cursor(ARROW);
      key = 0;
      if ( ! ContinuousLoop )
      {
        noLoop();
        redraw();
      }
    }
    
    return;
  }
  
  if ( k == CODED )  // $$$
  {
      switch ( keyCode )
      {
        case UP:
          if ( SelSl >= 0 )
          {
            Sl[SelSl].moveShape(0,-1);
            redraw();
          }
          break;
          
        case DOWN:
          if ( SelSl >= 0 )
          {
            Sl[SelSl].moveShape(0,1);
            redraw();
          }
          break;
          
        case LEFT:
          if ( SelSl >= 0 )
          {
            Sl[SelSl].moveShape(-1,0);
            redraw();
          }
          break;
          
        case RIGHT:
          if ( SelSl >= 0 )
          {
            Sl[SelSl].moveShape(1,0);
            redraw();
          }
          break;
      }

      return;
  }
  
  if ( (k == 's') || (k == 'S') )
  {
    // Save configuration
      if ( Mode < 2 )
      {
        String Jxml = PathData+FileName+".xml";  // Junction config
        SaveGraph(Jxml);
        contextHelp("Junction configuration saved");
      }
      
      return;
  }
    
  if ( (k == 'c') || (k == 'C') )
  {
    // Configure movements and phases
      cursor(ARROW);
      Mode = 1;
      SelSl = -1;
      SelMv = -1;
      DrgMv = -1;
      if ( JS.nph == 0 )
        JS.newPhase(30);
      JS.sel = 0;
      UnselectAllSl();
      UpdateMovements();
      contextHelp("Phase 1: Drag & drop from a stop line to create a new movement");
      redraw();

      return;
  }
    
  if ( (k == 't') || (k == 'T') )
  {
    // Run test mode
      //noCursor();
      Mode = 2;
      Mode3D = false;
      UnselectAllSl();
      JS.sel = -1;
      if ( JS.nph > 0 )
        JS.sel = 0;
      Simd.init();
      JS.init();
      contextHelp("");
      //frameRate(1);
      loop();
      
      return;
  }
    
  if ( k == ' ' )
  {
      // Next phase
      if ( Mode == 2 )
      {
        if ( JS.nph > 0 )
        {
          JS.sel++;
          if ( JS.sel >= JS.nph )
            JS.sel = 0;
          redraw();
        }
      }
      return;
  }
    
  if ( (k >= '0') && (k <= '9') )
  {
      switch ( int(Mode) )
      {
        case 0:  // Set number of lanes
          if ( ((Lsz == 0) && (Sl[0].del == false)) || (SelSl == 0) )
          {
            Sl[0].setLanes(int(k-'0'));
            UpdateAllSl();
          }
          break;
        
        case 1:
          int n = int(k-'1');
          if ( (n >= 0) && (n < JS.nph) )
          {
            JS.sel = n;
            contextHelp("Phase "+(n+1)+": Drag & drop from a stop line to create a new movement");
            UnselectMovement();
          }
          break;

        case 2:
          if ( k == '3' )
          {
            if ( Mode3D )
              Mode3D = false;
            else
              Mode3D = true;
          }
          break;
      }
      redraw();

      return;
  }

  if ( (k == 'l') || (k == 'L') )
  {
    // Load next sample file
      if ( Mode == 0 )
        LoadNextSampleFile();
        
      return;
  }
      
  if ( (k == 'n') || (k == 'N') )
  {
    // New file
      if ( Mode == 0 )
      {
        ResetSl();
        ResetMv();
        JS.reset();
      }
      else if ( Mode == 1 )
      {
        // New phase
        if ( JS.nph < JS.Maxph )
        {
          JS.newPhase(30);
          JS.sel = JS.nph - 1;
          contextHelp("Phase "+(JS.sel+1)+": Drag & drop from a stop line to create a new movement");
          UnselectMovement();
        }
      }
      
      return;
  }

  if ( (k == 'r') || (k == 'R') )
  {
    // Remove phase
      if ( Mode == 1 )
      {
        JS.removePhase();
      }
      
      return;
  }

  if ( k == '-' )
  {
      if ( Mode == 2 )
      {
        if ( Simulation == false )
        {
          // Zoom in
          if ( Scale < 1 )
          {
            Scale *= 2;
            redraw();
          }
        }
        else
        {
          // Slow down simulation
          Simd.speedDown();
        }
      }
      
      return;
  }

  if ( k == '+' )
  {
      if ( Mode == 2 )
      {
        if ( Simulation == false )
        {
          // Zoom out
          if ( Scale >= 0.125 )
          {
            Scale /= 2;
            redraw();
          }
        }
        else
        {
          // Speed up simulation
          if ( CPULimit == false )
            Simd.speedUp();
        }
      }
      return;
  }

  if ( (k == 'b') || (k == 'B') )
  {
    // Toggle junction renderer
      BackMode++;
      if ( BackMode > 4 )
        BackMode = 0;
      if ( ((Bkimg == null) && (Bkshp == null)) && (BackMode > 2) )
        BackMode = 0;
      if ( (BackMode != 0) && (BackMode != 3) )
        RenderMovementsPG();
      redraw();
      return;
  }
    
  if ( (k == 'm') || (k == 'M') )
  {
    // Toggle simulation mode
      if ( Mode == 2 )
      {
        if ( Simulation == false )
        {
          InitSimulator(Maxsl,Sl,Maxmv,Mv,Lsz);  // $$$
          Simulation = true;
          Paused = false;
          Simd.init();
          //loop();
        }
        else
        {
          Simulation = false;
          Paused = true;
          //noLoop();
          contextHelp("");
        }
      }
      return;
  }
    
  if ( (k == 'y') || (k == 'Y') )
  {
    // Toggle birdeye mode
    if ( Mode == 2 )
    {
      if ( Simulation == true )
      {
        RenderMovementsPG();
        ToggleBirdEye();
      }
    }
    return;
  }
      
  if ( (k == 'd') || (k == 'D') )
  {
      // Toggle debug mode
      if ( Mode == 2 )
      {
        if ( Simulation == true )
          ToggleDebugMode();
      }
      return;
  }
      
  if ( (k == 'p') || (k == 'P') )
  {
    // Pause simulation
      if ( Mode == 2 )
      {
        if ( Simulation == true )
        {
          if ( Paused )
          {
            Paused = false;
            loop();
          }
          else
          {
            Paused = true;
            noLoop();
          }
        }
      }
      return;
  }
}

// Load next sample file

void LoadNextSampleFile()
{
  ResetSl();
  ResetMv();
  JS.reset();
  Jid++;
  if ( Jid > 4 )
  {
    Bkimg = null;
    Bkshp = null;
    Jid = 0;
  }
  
  if ( Jid > 0 )
  {
    if ( Jid < 4 )
    {
      try
      {
        String Jjpg = PathData+SampleFileName+Jid+".jpg";  // Junction image background
        Bkimg = loadImage(Jjpg);
        Bkshp = null;
      }  
      catch ( Exception e )
      {
        Bkimg = null;
        Jid = 0;
      }
      if ( Bkimg != null )
        image(Bkimg,width/2,height/2);
    }
    else
    {
      try
      {
        String Jshp = PathData+SampleFileName+Jid+".svg";  // Junction shape background
        Bkshp = loadShape(Jshp);
        Bkimg = null;
      }
      catch ( Exception e )
      {
        Bkshp = null;
        Jid = 0;
      }
      if ( Bkshp != null )
        shape(Bkshp,0,0,width,height);
    }

    // Load XML file
    String Jxml = PathData+SampleFileName+Jid+".xml";  // Junction config
    LoadGraph(Jxml);
    RenderMovementsPG();
  }
}

// Create menus
MenuBar CreateMenu0()
{
  MenuBar m = new MenuBar(24,color(200));
  m.addButton(int('C')," Phases     ","Enter phases configuration mode",null);
  m.addButton(int('B')," Background ","Change background mode",null);
  m.addButton(int('T')," Test Mode  ","Enter test mode",null);
  //m.addButton(int('L')," Load File  ","Load new sample file",null);
  m.addButton(int('S')," Save ","Save configuration",null);
  m.addButton(int('N')," Reset ","Initializes configuration",null);

  return(m);
}

MenuBar CreateMenu1()
{
  MenuBar m = new MenuBar(24,color(200));
  m.addButton(int('N')," Add Phase    ","Add new phase",null);
  m.addButton(int('R')," Remove Phase ","Remove this phase",null);
  m.addButton(int('X')," Back ","Back to junction configuration mode",null);
  
  return(m);
}

MenuBar CreateMenu20()
{
  MenuBar m = new MenuBar(24,color(200));
  m.addButton(int(' ')," Next Phase ","Force next phase",null);
  m.addButton(int('B')," Background ","Change background mode",null);
  m.addButton(int('M')," Simulation ","Start simulation",null);
  m.addButton(int('+')," Zoom out ","Zoom out view",null);
  m.addButton(int('-')," Zoom in  ","Zoom in view",null);
  int b3d = m.addButton(int('3')," 3D ","3D view",null);
  m.addButton(int('X')," Back ","Back to configuration mode",null);
  if ( ! Enable3D )
    m.disable(b3d);
  
  return(m);
}

MenuBar CreateMenu21()
{
  MenuBar m = new MenuBar(24,color(200));
  m.addButton(int(' ')," Next Phase ","Force next phase",null);
  m.addButton(int('B')," Background ","Change background mode",null);
  m.addButton(int('M')," Simulation ","Restart simulation",null);
  m.addButton(int('+')," Speed Up   ","2X simulation speed",null);
  m.addButton(int('-')," Speed Down ","Slow down simulation speed",null);
  int b3d = m.addButton(int('3')," 3D ","Toggle 3D view",null);
  int bby = m.addButton(int('y')," Bird Eye ","Toggle Bird eye view",null);
  m.addButton(int('X')," Back       ","Back to configuration mode",null);
  if ( ! Enable3D )
  {
    m.disable(b3d);
    //m.disable(bby);
  }
  
  return(m);
}

// Header tool bar
void DrawHeader()
{
  int y = int(HeaderH/2)-2;
  
  textSize(16);
  //strokeWeight(0);  // $$$
  noStroke();
  textAlign(LEFT, CENTER);
  switch ( int(Mode) )
  {
    case 0: // Configure stop lines and acces links
      fill(200,200,200);
      rect(0,0,width,HeaderH);
      fill(0,0,0);
      text("C: Configure Phases  |  B: Background Mode |  S: Save Configuration  |                                  ESC: Exit",5,y);
      break;

    case 1: // Configure movements & phases
      fill(200,200,200);
      rect(0,0,width,HeaderH);
      fill(0,0,0);
      text("Select Phase to configure 1..9  |  N: New Phase                           |  X: Exit to stop lines configuration",5,y);
      break;

    case 2: // Test Mode
      fill(200,200,200);
      rect(0,0,width,HeaderH);
      fill(0,0,0);
      if ( Simulation == false )
      {
        if ( Enable3D )
          text("SPACE: Next Phase  |  M: Start simulation  |  R: Background  |  +/-: Zoom  |  3: 3D                   |  X: Exit",5,y);
        else
          text("SPACE: Next Phase  |  M: Start simulation  |  R: Background  |  +/-: Zoom                             |  X: Exit",5,y);
      }
      else
      {
        if ( Enable3D )
          text("SPACE: Next Phase  |  P: Pause  |  R: Background |  +/-: Time Speed  |  Y: Bird Eye  |  3: 3D         |  X: Exit",5,y);
        else
          text("SPACE: Next Phase  |  P: Pause  |  B: Background |  +/-: Time Speed                                   |  X: Exit",5,y);
      }
      break;
  }
}

// Context help line
void DrawFooter()
{
  int yhelp;
  
  if ( Mode < 2 )
  {
    if ( Mode == 1 )
    {
      JS.display();
      yhelp = height - 2*FooterH;
    }
    else
      yhelp = height - FooterH;
    
    int y = yhelp + int(FooterH/2) - 2;
    textSize(16);
    //strokeWeight(0);  // $$$
    noStroke();
    if ( millis() < Warnt )
    {
      fill(240,50,50);
      rect(0,yhelp,width,FooterH);
      fill(255,255,255);
      textAlign(LEFT, CENTER);
      text(Warns,5,y);
    }
    else
    {
      fill(240,240,50);
      rect(0,yhelp,width,FooterH);
      fill(0,0,0);
      textAlign(LEFT, CENTER);
      text(Helps,5,y);
    }
  }
  else
    JS.display();
}



// Initialization function
void setup()
{
  if ( Enable3D )
    size(800, 600, P3D);
  else
    size(800, 600);
  
  //PGraphics pg3 = g;
  
  stroke(0);
  textSize(16);
  //rectMode(CENTER);
  strokeCap(SQUARE);
  cursor(ARROW);
  background(0);
  imageMode(CENTER);
  ellipseMode(RADIUS);
  // blendMode(ADD);
  //textSize(14);
  //textAlign(CENTER,CENTER);
  if ( ! ContinuousLoop )
    noLoop();

  // Load background image
  try
  {
    String Jjpg = PathData+FileName+".jpg";  // Junction image background
    Bkimg = loadImage(Jjpg);
  }  
  catch ( Exception e )
  {
    Bkimg = null;
  }

  if ( Bkimg != null )
    image(Bkimg,width/2,height/2);

  // Load background shape
  if ( Bkimg == null )
  {
    try
    {
      String Jshp = PathData+FileName+".svg";  // Junction shape background
      Bkshp = loadShape(Jshp);
    }
    catch ( Exception e )
    {
      Bkshp = null;
    }
    
    if ( Bkshp != null )
      shape(Bkshp,0,0,width,height);
  }
  
  
  // Junction timing structure
  JS = new JStruct();
  JS.setControl(0,height-FooterH,width,FooterH);

  // Init stoplines array
  for ( int i=0 ; i<Maxsl ; i++ )
  {
    Vertex c = new Vertex(0,0);
    Sl[i] = new StopLine(c,c);
    Sl[i].del = true;
  }
  
  // Init movements array
  for ( int i=0 ; i<Maxmv ; i++ )
  {
    Mv[i] = new Movement(-1,-1);
  }
    
  // Load XML file
  String Jxml = PathData+FileName+".xml";  // Junction config
  LoadGraph(Jxml);
  
  pg = createGraphics(width,height);
  RenderMovementsPG();

  // Create arrows shapes
  CreateArrows();
  
  // Create menus
  Menu0 = CreateMenu0();
  Menu1 = CreateMenu1();
  Menu20 = CreateMenu20();
  Menu21 = CreateMenu21();
  MainMenu = Menu0;

  contextHelp("Click & drag to create a new stop line / access point");
}

float mX = -1;
float mY = -1;
float DragX = 0;
float DragY = 0;
float Rot = 0;
float Tilt = PI/4;
float Zoom = -250;

int backmsec = 0;

// Draw function (called every time a stop line added or changed)
void draw()
{
  // Measure drawing time to detect CPU limit
  int endmsec;
  int startmsec = millis();
  //println((startmsec - backmsec));
  backmsec = startmsec;
  
  background(0);

  if ( Mode == 2 )
  {
    // Run mode
    if ( Mode3D && (BirdEye == false) && Enable3D )
    {
      if ( mousePressed )
      {
        if ( mY > 0 )
          DragY = mY - mouseY;
  
        if ( mX > 0 )
          DragX = mX - mouseX;
          
        // Apply transformation
        //pushMatrix();
        Rot += (PI*DragX/width)/2;
        //println("AngR: "+degrees(angr));
        Tilt += PI*DragY/height;
      }
      mX = mouseX;
      mY = mouseY; 
      PVector r = new PVector(width/2,height/2);
      PVector s = r.get();
      r.rotate(Rot);
      r.sub(s);
      translate(-r.x,-r.y,0);
      translate(0, 0,-150);
      //rotateX(PI*(DragY/(2*height) + 0.25));
      rotateX(Tilt);
      //rotateX(tilt*(PI/2-angr));
      //rotateY(tilt*angr);
      rotateZ(Rot);
      translate(0, 0,Zoom*Rot);
      //translate(0, 0,-250);
    }
  }
    
  //if ( (Mode3D == false) && BirdEye && Simulation )
    //translate(0,0,-2000);

  if ( BackMode > 0 )
  {
    if ( Enable3D )
      translate(0,0,-1);
  }

  int bkm;
  if ( BirdEye )
    bkm = 1;
  else
    bkm = BackMode;
    
  switch ( int(bkm) )
  {
    case 0:  // None
      break;
    
    case 1:  // Render default
      background(0,70,0);
      image(pg,width/2,height/2,width*Scale,height*Scale);
      break;
    
    case 2:  // Mask only
      tint(#A06080,190);
      image(pg,width/2,height/2,width*Scale,height*Scale);
      noTint();
      break;

    case 3:  // Sat or SVG
      if ( Bkimg != null )
        image(Bkimg,width/2,height/2,width*Scale,height*Scale);
      else if ( Bkshp != null )
        shape(Bkshp,0,0,width,height);
      break;
    
    case 4:  // Mask & Sat or SVG
      if ( (Bkimg != null) || (Bkshp != null) )
      {
        if ( Bkimg != null )
          image(Bkimg,width/2,height/2,width*Scale,height*Scale);
        else
          shape(Bkshp,0,0,width,height);
          
        tint(#A06080,190);
        image(pg,width/2,height/2,width*Scale,height*Scale);
        noTint();
      }
      break;
  }

  if ( BackMode > 0 )
  {
    if ( Enable3D )
      translate(0,0,1);
  }

  switch ( int(Mode) )
  {
    case 0: // edit stop line
      MainMenu = Menu0;
      for ( int i=0 ; i<Maxsl ; i++ )
        Sl[i].display();
      break;
    
    case 1: // edit movements
      MainMenu = Menu1;
      if ( JS.sel >= 0 )
      {
        JS.Ph[JS.sel].display();
        if ( DrgMv >= 0 )
          Mv[DrgMv].display(color(250,0,0));
      }
      else
      {
        for ( int i=0 ; i<JS.nph ; i++ )
          JS.Ph[i].display();
      }
      for ( int i=0 ; i<Maxsl ; i++ )
        Sl[i].display();
      break;
    
    case 2: // Run mode, render phases
      MainMenu = Menu20;
      if ( JS.sel >= 0 )
      {
        pushStyle();
        if ( Scale < 1 )
        {
          fill(150,50,100,190);
          if ( ! BirdEye )
            ellipse(width/2,height/2,width*Scale/2,width*Scale/2);
          float sz = width*Scale/7;  // 5.5
          JS.Ph[JS.sel].renderMov(sz);
        }
        else
        {
          float sz = 1.3*Lsz*Scale;
          JS.Ph[JS.sel].renderMov(sz);
        }
        popStyle();

        if ( Simulation == true )
        {
          MainMenu = Menu21;
          JSys.run(JS);
      
          //if ( (Mode3D == false) && BirdEye )
            //translate(0,0,2000);
      
          Simd.display(millis());
        }

        // Run phase timer
        //int simt = 0;
        int simt = Simd.msec();
        int np = JS.run(simt);  // !!! tiempo y fases
        if ( np >= 0 )
        {
          JS.sel = np;
          //println("Phase "+JS.sel);
        }
      }
      break;
      
      default:
        break;    
  }
  
  if ( Mode3D == false )
  {
    if ( ContinuousLoop )
    {
      int k = MainMenu.run();
      if ( k > 0 )
        KeyPressed(k);
    }
    else
      DrawHeader();
      
    DrawFooter();
    
    //noLoop();
  }
  
  // Loop set to 60 Hz
  endmsec = millis();
  if ( endmsec - startmsec > 16 )
    CPULimit = true;
  else
    CPULimit = false; 
}

