/*
  @pjs globalKeyEvents="true";
*/
// Menu class
// Carlos Gil 5/2014 

class MenuBut
{
  float x;
  float y;
  float w;
  float h;
  String txt;
  String hint;
  float hsz;
  int k;
  PImage ic;
  boolean pressed;
  boolean over;
  boolean disabled;
  
  MenuBut(float x, float y, float w, float h, String txt, String hint, int k, PImage ic)
  {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.txt = txt;
    this.hint = hint;
    this.k = k;
    this.ic = ic;
    hsz = textWidth(hint);
    pressed = false;
    disabled = false;
  }
  
  void enable()
  {
    disabled = false;
  }
  
  void disable()
  {
    disabled = true;
  }
  
  void draw(float xm, float ym)
  {
    if ( ic != null )
      image(ic,x,y,w,h);

    pushStyle();
    textAlign(LEFT,BASELINE);
    if ( txt != null )
    {
      if ( ! disabled )
      {
        if ( over )
        {
          strokeWeight(1);
          stroke(10,10,250);
          line(x,y,x+w,y);
          line(x,y,x,y+h);
          line(x+w,y,x+w,y+h);
          line(x,y+h,x+w,y+h);
          if ( hint != null )
          {
            fill(255,255,0);
            noStroke();
            rect(xm+16,ym+16,hsz,20);
            fill(0);
            text(hint,xm+16,ym+32);
          }
          fill(10,10,250);
        }
        else
          fill(0);
      }
      else
        fill(150);

      if ( pressed )
        text(txt,x+3,y+17);
      else
        text(txt,x+2,y+16);
    }
    
    /*
    if ( pressed )
    {
      strokeWeight(1);
      if ( disabled )
        stroke(150);
      else
        stroke(255);
      line(x,y,x+w,y);
      line(x,y,x,y+h);
      //strokeWeight(1);
      //stroke(255);
      line(x+w,y,x+w,y+h);
      line(x,y+h,x+w,y+h);
    }
    else
    {
      strokeWeight(1);
      stroke(255);
      line(x,y,x+w,y);
      line(x,y,x,y+h);
      strokeWeight(2);
      stroke(50);
      line(x+w,y,x+w,y+h);
      line(x,y+h,x+w,y+h);
    }
    
    if ( disabled )
    {
      fill(100,150);
      rect(x,y,w,h);
    }
    */
    popStyle();

  }
  
  int run(float xm, float ym)
  {
    draw(xm,ym);
    if ( disabled )
      return(0);
      
    if ( (xm > x) && (xm < x+w) && (ym > y) && (ym < y+h) )
    {
      over = true;
      if ( ! mousePressed )
      {
        if ( pressed )
        {
          pressed = false;
          return(k);
        }
      }
      else
      {
        if ( ! pressed )
          pressed = true;
      }
    }
    else
    {
      over = false;
      if ( pressed )
        pressed = false;
    }
    
    return(0);
  }
}

class MenuBar
{
  float h;
  float w;
  float bh;
  float bg;
  color mbc;
  int maxb;
  int nb;
  MenuBut[] mba;

  MenuBar(float h, color c)
  {
    this.h = h;
    mbc = c;
    bg = 4;
    bh = h - bg;
    w = bg;
    maxb = 10;
    mba = new MenuBut[maxb];
    nb = 0;
  }
  
  int addButton(int k, String txt, String hint, PImage ico)
  {
    if ( nb < maxb - 1 )
    {
      float x = w;
      float y = bg/2 - 1;
      float tw = textWidth(txt) + 4;
      if ( w + tw > width )
        return(-1);
        
      mba[nb] = new MenuBut(x,y,tw,bh,txt,hint,k,ico);
      w += (tw + bg);
      nb++;
      
      return(nb-1);
    }
    
    return(-1);
  }
  
  void disable(int n)
  {
    if ( (n >= 0) && (n < nb) )
      mba[n].disable();
  }
  
  void enable(int n)
  {
    if ( (n >= 0) && (n < nb) )
      mba[n].enable();
  }
  
  int run()
  {
    noStroke();
    fill(mbc);
    rect(0,0,width,h);
    for ( int i=0 ; i<nb ; i++ )
    {
      int k = mba[i].run(mouseX,mouseY);
      if ( k > 0 )
        return(k);
    }
    
    return(0);
  }
}

/****************************
MenuBar Menu;
MenuBut Mb;

void setup()
{
  size(800, 600, P2D);
  
  stroke(0);
  textSize(16);
  //rectMode(CENTER);
  strokeCap(SQUARE);
  cursor(ARROW);
  background(0);

  // Load background image
  PImage ico = loadImage("ico.png");
  Menu = new MenuBar(24,color(200));
  Menu.addButton(100,"K100  ","Button 100");
  Menu.addButton(200,"K200  ","Button 200");
  Menu.addButton(300,"K300  ","Button 300");
}


// Draw function (called every time a stop line added or changed)
void draw()
{
  background(100);
  int k = Menu.run();
  switch ( k )
  {
    case 100:
      Menu.disable(1);
      break;
  
    case 300:
      Menu.enable(1);
      break;
  }
}
*********************/
