
Planet earth;
Moon moon;
Planet[] planets=new Planet[2];
Ship ship;
int G=1;
float rotateradian=0.3;
float a_rate=0.002;
float max_a=0.03;
float max_velocity=3;

void setup(){
  size(1000,1000);
  frameRate(60);
  earth=new Planet(new PVector(width/2,height/2),100,color(0,0,255),400);
  moon=new Moon(new PVector(50,300),50,color(100,100,100),80,earth);
  planets[0]=earth;
  planets[1]=moon;
  ship=new Ship(new PVector(10,10),new PVector(0,0),planets);
}


void draw(){
   background(255);
   moon.orbit();
   earth.display();
   moon.display();
   ship.display();
   text(ship.a,900,900);
   text(ship.velocity.mag(),900,920);
}

class Planet{
  PVector location;
  int radius;
  color cl;
  int mass;
  PShape s;
  Planet( PVector l,int r,color c,int m){
    location=l;
    radius=r;
    cl=c;
    mass=m;
  }
  void display(){
    fill(cl);
    circle(location.x,location.y,radius*2);
  }
}

class Moon extends Planet{
  public float angularspeed=0.0005;
  float angle=0;
  Planet parent;
  PVector prev;
  Moon(PVector l,int r,color c,int m,Planet p){
    super(l,r,c,m);
    parent=p;
    prev=new PVector(0,0);
    prev.x=parent.location.x+300*cos(angle-angularspeed);
    prev.y=parent.location.y+300*sin(angle-angularspeed);
    location.x=parent.location.x+300*cos(angle);
    location.y=parent.location.y+300*sin(angle);
  }
  void orbit(){
    prev.x=location.x;
    prev.y=location.y;
    location.x=parent.location.x+300*cos(angle);
    location.y=parent.location.y+300*sin(angle);
    angle+=angularspeed;
    
  }
}

class Ship{
  PVector center;
  PVector p1,p2,p3;
  PVector l1,l2,l3;
  PVector velocity;
  PVector direction;
  float angle;
  float a;
  int radius;
  Planet[] planets;
  
  
  Ship(PVector l,PVector v,Planet[] p){
    center=l;
    velocity=v;
    direction=new PVector(1,0);
    planets=p;
    angle=0;
    a=0;
    radius=10;
    p1=new PVector(10,0);
    p2=new PVector(-5,7);
    p3=new PVector(-5,-7);
    updateShip();
  }
  
  
  
  void updateShip(){
    l1=PVector.add(center,p1);
    l2=PVector.add(center,p2);
    l3=PVector.add(center,p3);
  }
  
  void rotateShip(float r){
    p1.rotate(r);
    p2.rotate(r);
    p3.rotate(r);
    angle+=r;
    angle%=2*PI;
  }
  
  void move(){
    float force;
    int i;
    
    for (i=0;i<2;i++){
      float dist=center.dist(planets[i].location);
      force=(G*planets[i].mass)/(dist*dist);
      PVector g=PVector.sub(planets[i].location,center).normalize().mult(force);
      velocity.add(g);
    }
    
    if(a>0){
      velocity.add(PVector.fromAngle(angle).mult(a));
    }
    //collisioncheck(planets[0]);
    velocity.limit(max_velocity);
    center.add(velocity);
    collision(planets);
  }
  void display(){
    move();
    boundcheck();
    updateShip();
     
    triangle(l1.x,l1.y,l2.x,l2.y,l3.x,l3.y);

  }
  void boundcheck(){
    float x=center.x;
    float y=center.y;
    if(x<0){
        reflect(0);
    }else if(x>width){
        reflect(PI);
    }else if(y<0){
        reflect(PI*3/2);
    }else if(y>height){
        reflect(PI/2);
    }
  }
  void reflect(float angle){
      float tmp=velocity.heading();
      velocity.mult(-1);
      velocity.rotate((angle-velocity.heading())*2);
      rotateShip(-tmp+velocity.heading());
  }
  void reflect2(float angle){
      velocity.mult(-1);
      velocity.rotate((angle-velocity.heading())*2);
  }
  
  boolean collisioncheck(Planet p){
     float dist=PVector.dist(center,p.location);
     if(dist<radius+p.radius){
       return true;
     }
     return false;
  }
   void collision(Planet[] p){
     boolean landed=false;
     for(int i=0;i<p.length;i++){
        if(collisioncheck(p[i])==true){
           landed=sat(l1,l2,l3,p[i]);
           if(landed==true){
             PVector landsurface=PVector.sub(center,p[i].location).normalize();
             PVector repulse=PVector.mult(landsurface,velocity.dot(landsurface)*-1);
            
             if(velocity.mag()>1){
               reflect2(landsurface.heading());
               center.add(PVector.mult(velocity,2.4));
               velocity.mult(0.6);
             }else{
                velocity.add(repulse);
                if(a==0){
                   if(velocity.mag()>0.05){
                       velocity.mult(0.8);
                   }else{
                      velocity.setMag(0);
                      if(p[i].getClass()==Moon.class){
                        println("landed on moon");
                        Moon m=(Moon) p[i];
                        
                        center.add(PVector.sub(m.location,m.prev));
                      }
                   } 
                }
             }
     
             
             return;
           }
        }
     }
   }
  
  boolean sat(PVector v1,PVector v2,PVector v3,Planet p){ //<>//
    PVector closest=new PVector(0,0);
    PVector[] list=new PVector[3];
    PVector[] axistriangle=new PVector[3];
    PVector mtv;
    float mtv_dist;
    
    list[0]=v1;
    list[1]=v2;
    list[2]=v3;
    axistriangle[0]=PVector.sub(list[0],list[1]);
    axistriangle[0].rotate(PI/2).normalize(); //<>//
    axistriangle[1]=PVector.sub(list[1],list[2]);
    axistriangle[1].rotate(PI/2).normalize();
    axistriangle[2]=PVector.sub(list[2],list[0]);
    axistriangle[2].rotate(PI/2).normalize();
    
    
    float dist;
    float mindist;
    mindist=list[0].dist(p.location);
    closest=list[0];
   
   
    for(int i=1;i<3;i++){
      dist=list[i].dist(p.location);
      if(dist<mindist){
        mindist=dist;
        closest=list[i];
      }
    }
    //circle axis check
    PVector axisCircle=PVector.sub(closest,p.location).normalize();
   
   
    float[] T=new float[2];
    projectVertices(list,axisCircle,T);
   
   
    
    float[] C=new float[2];
    projectCircle(p.location,p.radius,axisCircle,C);
    if(T[0]>=C[1] || C[0]>=T[1]){
      //gap found return now
      return false;
    }
    mtv=axisCircle;
    mtv_dist=T[0]-C[1];
 
    mindist=abs(mtv_dist);
   
    
    
    
    //vertices axis check
    for(int i=0;i<3;i++){
      float[] T2=new float[2];
      float[] C2=new float[2];
      projectVertices(list,axistriangle[i],T2);

      
      projectCircle(p.location,p.radius,axistriangle[i],C2);
      
      if(T2[0]>=C2[1] || C2[0]>=T2[1]){
        
        return false;
      }
      float tmpdist=min(abs(T2[0]-C2[1]),abs(C2[0]-T2[1]));
      
      if(tmpdist<mindist){
        mindist=tmpdist;
        mtv=axistriangle[i];
        mtv.mult(-1);
      }
    }
   
    
    center.add(mtv.mult(mindist));
    return true;
    
  }
  
  void projectVertices(PVector[] v,PVector Axis,float[] minmax){
    float min=v[0].dot(Axis);
    float max=min;
    for(int i=1;i<3;i++){
      float tmp=v[i].dot(Axis);
      if(tmp<min){
        min=tmp;
      }
      if(tmp>max){
        max=tmp;
      }
    }
    minmax[0]=min;
    minmax[1]=max;
  }
  
  void projectCircle(PVector center,int radius,PVector Axis,float[] minmax){
    PVector p=PVector.mult(Axis,radius);
    PVector Pmax=PVector.add(center,p);
    PVector Pmin=PVector.sub(center,p);
    float min=Pmin.dot(Axis);
    float max=Pmax.dot(Axis);
    if(min>max){
      float tmp=min;
      min=max;
      max=tmp;
    }
    minmax[0]=min;
    minmax[1]=max;
    
  }

}

void keyPressed(){
  if ( key =='W' || key=='w'){
    if(ship.a<max_a){
      ship.a+=a_rate;
    }
  }else if (key =='A' || key=='a'){
    ship.rotateShip(-rotateradian);
  }else if ( key =='D' || key=='d'){
    ship.rotateShip(rotateradian);
  }else if (key =='S' || key=='s'){
     ship.a-=a_rate;
     if(ship.a<0){
       ship.a=0;
     }
  }
}

void mouseDragged(){
  ship.center.x=mouseX;
  ship.center.y=mouseY;
}
