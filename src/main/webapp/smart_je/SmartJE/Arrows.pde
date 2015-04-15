// Movement arrows creation and rendering

boolean Arrows = false;
float DefaultSz = 10;

PVector[] Arl = new PVector[9];  // Arrow left shape
PVector[] Arr = new PVector[9];  // Arrow right shape
PVector[] Arf = new PVector[7];  // Arrow front shape

void CreateArrowR()
{
  float al = 0.4*DefaultSz;
  float aw = DefaultSz/2.4;
  float e = aw/2;
  
  Arr[0] = new PVector(0,-aw/2);
  Arr[1] = new PVector(al+aw,0);
  Arr[2] = new PVector(0,aw+e/2);
  Arr[3] = new PVector(e,0);
  Arr[4] = new PVector(-(aw/2+e),aw/2+e);
  Arr[5] = new PVector(-(aw/2+e),-(aw/2+e));
  Arr[6] = new PVector(e,0);
  Arr[7] = new PVector(0,-e/2);
  Arr[8] = new PVector(-al,0);
}

void CreateArrowR2()
{
  float al = 0.8*DefaultSz;
  float ar = 0.6*DefaultSz;
  float arcos = ar*sqrt(2)/2; // !!!
  float aw = DefaultSz/2.5;
  float awcos = aw*sqrt(2)/2;
  float arcos2 = arcos - (aw-awcos);
  float al2 = al + aw - 2*awcos;
  float e = 0.5*awcos;
  
  Arr[0] = new PVector(0,-aw/2);
  Arr[1] = new PVector(al,0);
  Arr[2] = new PVector(arcos,arcos);
  Arr[3] = new PVector(e,-e);
  Arr[4] = new PVector(0,awcos+2*e);
  Arr[5] = new PVector(-awcos-2*e,0);
  Arr[6] = new PVector(e,-e);
  Arr[7] = new PVector(-arcos2,-arcos2);
  Arr[8] = new PVector(-al2,0);
}

void CreateArrowL()
{
  float al = 0.4*DefaultSz;
  float aw = DefaultSz/2.4;
  float e = aw/2;
  
  Arl[0] = new PVector(0,aw/2);
  Arl[1] = new PVector(al+aw,0);
  Arl[2] = new PVector(0,-(aw+e/2));
  Arl[3] = new PVector(e,0);
  Arl[4] = new PVector(-(aw/2+e),-(aw/2+e));
  Arl[5] = new PVector(-(aw/2+e),(aw/2+e));
  Arl[6] = new PVector(e,0);
  Arl[7] = new PVector(0,e/2);
  Arl[8] = new PVector(-al,0);
}

void CreateArrowL2()
{
  float al = 0.8*DefaultSz;
  float ar = 0.6*DefaultSz;
  float arcos = ar*sqrt(2)/2; // !!!
  float aw = DefaultSz/2.5;
  float awcos = aw*sqrt(2)/2;
  float arcos2 = arcos - (aw-awcos);
  float al2 = al + aw - 2*awcos;
  float e = 0.5*awcos;
  
  Arl[0] = new PVector(0,aw/2);
  Arl[1] = new PVector(al,0);
  Arl[2] = new PVector(arcos,-arcos);
  Arl[3] = new PVector(e,e);
  Arl[4] = new PVector(0,-(awcos+2*e));
  Arl[5] = new PVector(-(awcos+2*e),0);
  Arl[6] = new PVector(e,e);
  Arl[7] = new PVector(-arcos2,arcos2);
  Arl[8] = new PVector(-al2,0);
}

void CreateArrowF()
{
  float al = 0.7*DefaultSz;
  float ar = 0.5*DefaultSz;
  float arcos = ar*sqrt(2)/2; // !!!
  float aw = DefaultSz/2.4;
  float awcos = aw*sqrt(2)/2;
  float e = 0.5*sqrt(2)*awcos;
  
  Arf[0] = new PVector(0,aw/2);
  Arf[1] = new PVector(al+arcos,0);
  Arf[2] = new PVector(0,e);
  Arf[3] = new PVector((aw/2+e),-(aw/2+e));
  Arf[4] = new PVector(-(aw/2+e),-(aw/2+e));
  Arf[5] = new PVector(0,e);
  Arf[6] = new PVector(-al-arcos,0);
}

// Draw arrow shape scaled to the lane size
void DrawArrow(float x, float y, float a, PVector[] f, color c, float lsz)
{
  float scl = lsz/DefaultSz;
  PVector org = new PVector(x,y);
  PVector edge = new PVector();
  
//stroke(0,100,0);
  noStroke();
  //strokeWeight(1);
  fill(c);
  beginShape();
  vertex(x,y);
  for ( int i=0 ; i<f.length ; i++ )
  {
    edge = f[i].get();
    edge.mult(scl);
    edge.rotate(a);
    org.add(edge);
    vertex(org.x,org.y);
  }
  endShape(CLOSE);
}


// Draw full movement (test)
void DrawMovement(float x, float y, float r, float lsz, color col, int nl)
{
  for ( int i=0 ; i<nl ; i++ )
  {
    float xi = x + i*lsz*sin(r);
    float yi = y - i*lsz*cos(r);
    if ( i == 0 )
    {
      DrawArrow(xi,yi,r,Arl,col,1);
    }
    else
    {
      if ( i == nl-1 )
        DrawArrow(xi,yi,r,Arr,col,1);
      else
        DrawArrow(xi,yi,r,Arf,col,1);
    }
  }
}


// Create arrow shapes
void CreateArrows()
{
  if ( Arrows == false )
  {
    CreateArrowL();
    CreateArrowR();
    CreateArrowF();
    Arrows = true;
  }
}

