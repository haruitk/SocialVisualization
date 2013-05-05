// NOTE: You need to copy  ControlP5 into your local Processing>libraries folder
// I put it in our Google Drive 


/*
  Things left to do:
  1) Parsing of data (maybe into CSV format and using Lingpipe?) and populating g_emails (see required attributes in code) 
  2) Time Slider to set start time (year, month, day)
  3) Adapt code for Month View and Day View
  4) Add excitement meter, and other stats on the keyword?
  5) Color control
  6) Bugs
  
  Speed control
  Backward?
  Slider, and graph
*/
import controlP5.*; // If this doesn't compile, read above.
import ClassificationWrapper.*;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Date ;
import java.io.File;


// Set the palette
// Background
int backgroundColor;

// Border
int borderColor;

// Text
int textColor;

// Radar
int radarBackground;

// Email Info
int emailBackground;

void setPalette()
{
  // Background
 backgroundColor = color(0);

// Border
 borderColor = color(#00EE00);

// Radar
 radarBackground = backgroundColor;

// Email Info
 emailBackground = backgroundColor;
}


// Program Variables
View[] views; //0: daily, 1: monthly, 2: yearly
int curView; // ptr to current view (0: daily, 1: monthly, 2: yearly)
PImage backImg, backImgOn, forwardImg, forwardImgOn, playImg, pauseImg; //load the images in only one time to avoid out of memory error
PFont g_font;
int angle_count;
HashMap g_balls;
ArrayList<Email> g_emails;
ArrayList<Email> g_newEmails;
Ball g_subMenuBall;

ControlP5 cp5; // If this doesn't compile, scroll up and read instructions
Textarea g_submenu;


int g_yearStart, g_monthStart, g_dayStart, g_hourStart, curEmailPtr; // points to current email in arraylist for efficiency
int g_totalExcitement;
ArrayList g_totalExcitementLevels;
// State Configurations
boolean isPaused; // State control (whether it's paused or not)
boolean isForward; // State control (whether the time moves forward or backwards) // Let's not implement this cos it's troublesome
boolean isSubmenuOpen;

int updateSpeed; // the smaller, the faster, and must be a factor of 60 (the frame rate). 5,10, 15, 30
int pending_updateSpeed; // if not 0, then it'll update updateSpeed on the next revolution
// XY Configurations
int dotx,doty, radius; // Center dot for radar
int sub_rectx; // Frame of sub menu
int sub_recty;
int play_btnx, play_btny;
int back_btnx, back_btny;
int forward_btnx, forward_btny;

void setup() {
  size(1200, 780);
  setPalette();
  
  // Configure State Defaults
  isPaused = true;
  isForward = true;
  isSubmenuOpen = true;
  g_totalExcitement = 0;
  g_totalExcitementLevels = new ArrayList();
  angle_count = 0;
  
  // Configure XY Defaults
  dotx = doty = 400;
  sub_rectx = 750;
  sub_recty = 100;
  radius = 300;
  play_btnx = 370;
  play_btny = 730;
  back_btnx = play_btnx - 100;
  back_btny = play_btny;
  forward_btnx = play_btnx + 100;
  forward_btny = play_btny;  
  
  // Initialize Variables
  
  frameRate(60);
  updateSpeed = 15; // default
  pending_updateSpeed = 0;
  // Default frame rate is 60;
  // Do we want to update info twice a second?
  // We should update animation even if we're not updating info
  
  playImg = loadImage("play.png");
  pauseImg = loadImage("pause.png");
  
  g_font = createFont("Arial",16,true);
  
  cp5 = new ControlP5(this);
  g_submenu = cp5.addTextarea("txt")
                  .setPosition(770,120)
                  .setSize(360,360)
                  .setFont(createFont("arial",12))
                  .setLineHeight(14)
                  .setColor(color(borderColor))
                  .setColorBackground(color(emailBackground))
                  .setColorForeground(color(255,100));
                  ;
  g_submenu.setText("");
                    
  CallbackListener speedCB = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_RELEASED):
        case(ControlP5.ACTION_RELEASEDOUTSIDE):
        //println("Released");
        int v = (int) cp5.getController("Speed").getValue();
        switch(v)
        {
           case 1:
             pending_updateSpeed = 60;
             break;
           case 2:
             pending_updateSpeed = 30;
             break;
           case 3:
             pending_updateSpeed = 15;
             break;
           case 4:
           
             pending_updateSpeed = 5;
             break;
           case 5: 
            pending_updateSpeed = 2;
            break; 
        }
        break;
      }
    }
  };
   // add a vertical slider. meter:speed -- 5: 2, 4: 5, 3: 15, 2: 30, 1: 60 
   cp5.addSlider("Speed")
     .setPosition(50,320)
     .setSize(20,150)
     .setRange(1,5)
     .setValue(3)
     .setNumberOfTickMarks(5)
     .addCallback(speedCB)
     ;
  
  CallbackListener dailyViewCB = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_RELEASED):
        case(ControlP5.ACTION_RELEASEDOUTSIDE):
       curView = 0;
      cp5.getController("Daily_View").setColorCaptionLabel(#00EE00);
      cp5.getController("Monthly_View").setColorCaptionLabel(#f5f5f5);
    cp5.getController("Yearly_View").setColorCaptionLabel(#f5f5f5);  
    recreateSlider();
    g_totalExcitementLevels = new ArrayList();
    g_totalExcitement = 0; 
        break;
      }
    }
  };
   CallbackListener monthlyViewCB = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_RELEASED):
        case(ControlP5.ACTION_RELEASEDOUTSIDE):
       curView = 1;
      cp5.getController("Daily_View").setColorCaptionLabel(#f5f5f5);
      cp5.getController("Monthly_View").setColorCaptionLabel(#00EE00);
    cp5.getController("Yearly_View").setColorCaptionLabel(#f5f5f5);
    // update slider range 
    recreateSlider();
    g_totalExcitementLevels = new ArrayList();
    g_totalExcitement = 0; 
        break;
      }
    }
  };
   CallbackListener yearlyViewCB = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_RELEASED):
        case(ControlP5.ACTION_RELEASEDOUTSIDE):
       curView = 2;
      cp5.getController("Daily_View").setColorCaptionLabel(#f5f5f5);
      cp5.getController("Monthly_View").setColorCaptionLabel(#f5f5f5);
    cp5.getController("Yearly_View").setColorCaptionLabel(#00EE00); 
   recreateSlider();
   g_totalExcitementLevels = new ArrayList();
   g_totalExcitement = 0; 
        break;
      }
    }
  };
  // Add view buttons
  cp5.addButton("Daily_View")
     .setValue(0)
     .setPosition(860,765)
     .setSize(60,23)
     .setCaptionLabel("Daily View")
     .addCallback(dailyViewCB)
     ;
      
  cp5.addButton("Monthly_View")
     .setValue(0)
     .setPosition(925,765)
     .setSize(70,23)
     .setCaptionLabel("Monthly View")
     .addCallback(monthlyViewCB)
     ;
     cp5.getController("Monthly_View").setColorCaptionLabel(#00EE00);
  cp5.addButton("Yearly_View")
     .setValue(0)
     .setPosition(1000,765)
     .setSize(70,23)
     .setCaptionLabel("Yearly View")
     .addCallback(yearlyViewCB)
     ;
  // reposition the Label for controller 'slider'
  //cp5.getController("slider1").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  //cp5.getController("slider").getCaptionLabel().align(ControlP5.RIGHT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  

  
   
   curEmailPtr = 0;
  g_balls = new HashMap();
  g_emails = new ArrayList();
  g_newEmails = new ArrayList<Email>();
  g_subMenuBall = null;
  loadEmails();
  // Load data into g_emails (assumed already sorted by time)
  // CSV: thread_id, year, month, day, hour, excitement_level, sender, subject, body, datetime, keyword;
   // Hardcode for now 
   
   g_yearStart = g_emails.get(0).getYear();
   g_monthStart = g_emails.get(0).getMonth() ;
   g_dayStart = g_emails.get(0).getDay();
   g_hourStart = g_emails.get(0).getHour();
   //int viewType, int currentYear, int currentMonth, int currentDay, int currentHour
   
   views = new View[3];
  views[0] = new View("Daily View", 0, g_yearStart, g_monthStart, g_dayStart, -1); 
  views[1] = new View("Monthly View", 1, g_yearStart, g_monthStart, 0, 0);  
  views[2] = new View("Yearly View", 2, g_yearStart, 0, 1, 0);
  setTotalTimeForViews();
  curView = 1; // Default is monthly view.
  
  
   CallbackListener timeCB = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_RELEASED):
        case(ControlP5.ACTION_RELEASEDOUTSIDE):
        updateSliderTitle(true);
        reset();
        
        break;
        case(ControlP5.ACTION_BROADCAST):
        //println("Released");
        updateSliderTitle(false);
   
        break;
      }
    }
  };
  cp5.addSlider("Time")
     .setPosition(750,730)
     .setWidth(400)
     .setRange(1, views[curView].getTotalSliderTime()) // values can range from big to small as well
     .setValue(1)
     .showTickMarks(false)
     .setSliderMode(Slider.FLEXIBLE)
     .addCallback(timeCB)
     ;
     cp5.getController("Time").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  
  String slider_title;
   switch(curView)
       {
          case 0: // Day
            // Time unit for day is hours
            // Show Year, Month, Day, Hour
            slider_title = views[curView].getCurDay() + " " + getMonthOfYear(views[curView].getCurMonth()) + ", " + views[curView].getCurYear() ;                     
            break;
          
          case 2: // Year
            // Show Year, Month 
            slider_title = ""+views[curView].getCurYear();
            break;
          
          case 1: // Month  
          default:
            // Time units for month is days
            // Show Day, Month, Year      
            slider_title = getMonthOfYear(views[curView].getCurMonth()) + ", " + views[curView].getCurYear();
       }
  cp5.getController("Time").setValueLabel(slider_title); 
  
}
void loadEmails()
{
  //println(sketchPath(""));
  // hardcode for now
  File directory = new File(sketchPath("") + "/inbox/");  
  File[] files = directory.listFiles();  
  //println("files: " + files.length);
  // why directory.listFiles can only hold up to 1253 lenght?
  for (int index = 0; index < files.length; index++)  
  {  
     //Print out the name of files in the directory  
     //System.out.println(files[index].toString());  
      //println("loading emails: " + index); 
      try{
        EmailResult emailResult = new EmailResult(files[index].toString());
        if(emailResult == null)
        {
          return;
        }
        String[] from = emailResult.getFrom();  // returns an array of senders
        String[] to = emailResult.getTo();
        String subject = emailResult.getSubject();
        String body = emailResult.getBody();
        Boolean isReply = emailResult.IsReply();
        int excitementLevel = emailResult.getExcitementLevel();
        int day = emailResult.getDay();
        int month = emailResult.getMonth();
        int year = emailResult.getYear();
        int hour = emailResult.getHour();
        String dateTime = emailResult.getDateTime();
        
        if(year < 2001 || year > 2013 || day < 1 || day > 31 || month < 1 || month > 12)
        {
          continue;
        }
        
        int thread_id = index;
        
        if(isReply)
        {
          for(int i = 0; i < g_emails.size(); i++)
          {
            if(subject.equals(g_emails.get(i).getSubject()))
            {
              thread_id = g_emails.get(i).getThreadId();
              println("Got a reply");
              break;
            }
          }
        }
        
        // CSV: thread_id, year, month, day, hour, excitement_level, sender, subject, body, datetime, keyword;
        Email e = new Email(thread_id, year, month, day, hour, excitementLevel, from[0], subject, body, dateTime, "");
        
        // Sort the emails
        int sortIndex;
        for(sortIndex = g_emails.size()-1; sortIndex > -1; sortIndex--)
        {
          Email old = g_emails.get(sortIndex);
          // if we're larger than the current largest, we can add this thing
          if(year > old.getYear())
          {
            break;
          }
          else if(year == old.getYear())
          {
            if(month > old.getMonth())  // Same year, check months
            {
              break;
            }
            else if(month == old.getMonth())
            {
              if(day > old.getDay())  // Same year and month, check day
              {
                break;
              }
            }
          }
        }
        g_emails.add(sortIndex+1,e);
        if(sortIndex == -1)
        {
          println("Index of earliest: " + index + ", " + files[index].toString());
          println("Earliest month/year: " + g_emails.get(0).getMonth() + ":" + g_emails.get(0).getYear());
        }
    }
    catch(Exception e)
    {
      ;//println(e.toString());
    }
  }
  println("Earliest month/year: " + g_emails.get(0).getMonth() + ":" + g_emails.get(0).getYear());
}
void recreateSlider()
{
  cp5.getController("Time").remove();
   CallbackListener timeCB = new CallbackListener() {
    public void controlEvent(CallbackEvent theEvent) {
      switch(theEvent.getAction()) {
        case(ControlP5.ACTION_RELEASED):
        case(ControlP5.ACTION_RELEASEDOUTSIDE):
        updateSliderTitle(true);
        reset();
        
        break;
        case(ControlP5.ACTION_BROADCAST):
        //println("Released");
        updateSliderTitle(false);
   
        break;
      }
    }
  };
 cp5.addSlider("Time")
     .setPosition(750,730)
     .setWidth(400)
     .setRange(1, views[curView].getTotalSliderTime()) // values can range from big to small as well
     .setValue(1)
     .showTickMarks(false)
     .setSliderMode(Slider.FLEXIBLE)
     .addCallback(timeCB)
     ;
     cp5.getController("Time").getValueLabel().align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(0);
  
  String slider_title;
   switch(curView)
       {
          case 0: // Day
            // Time unit for day is hours
            // Show Year, Month, Day, Hour
            slider_title = views[curView].getCurDay() + " " + getMonthOfYear(views[curView].getCurMonth()) + ", " + views[curView].getCurYear() ;                     
            break;
          
          case 2: // Year
            // Show Year, Month 
            slider_title = ""+views[curView].getCurYear();
            break;
          
          case 1: // Month  
          default:
            // Time units for month is days
            // Show Day, Month, Year      
            slider_title = getMonthOfYear(views[curView].getCurMonth()) + ", " + views[curView].getCurYear();
       }
  cp5.getController("Time").setValueLabel(slider_title);  
}
void draw() {
  
  
  /*
    -- create static background
    If not paused
    {
       Update default changes for all
      Get new changes. 
      update element based on each new change.
      If submenu is open, maybe update submenu?
    }
    else // if paused
    {
      Do not update anything.
    }
    
    If there's a click on:
    {
      1) A circle: launch sub menu
      2) Pause: Pause the visualizer
      3) Dismiss Submenu : Close Sub menu   
    }
  */
  
  // Set static items
  setBackground();
  
  if(!isPaused)
  {
     angle_count++; 
  }
  
  
  // Update only two times per second, ie, if frame is 30 or 60...
  boolean doUpdate;
  doUpdate = (angle_count % updateSpeed) == 0;
  if(doUpdate)
  {
      updateAnimation();
    
    if(!isPaused)
    {
      // Update default changes  
      updateDefaultChanges();  
      
      // Update new information
      updateNewInfo();
      
    }
    
    // Redraws main view
      redrawMainView();
      
      // Update submenu if open
      if(isSubmenuOpen)
      {
         updateSubMenu(); 
      }
  }
  else
  {
    // update animation and redraw main view
    updateAnimation();
    redrawMainView();
    // Update submenu if open
      if(isSubmenuOpen)
      {
         updateSubMenu(); 
      }
  }
}

void setBackground()
{
  background(backgroundColor);
  // Draw main view
  
  
  // radar
  stroke(borderColor);
  strokeWeight(3);
  fill(radarBackground);
  ellipse(dotx,doty,600,600);
 
 
  // Create Sub menu Frame
  stroke(borderColor);
  strokeWeight(3);
  fill(emailBackground);
  rect(sub_rectx,sub_recty,400,400, 7);
  
  // Draw visualization title
  fill(borderColor);
  textFont(g_font, 20);
  textAlign(LEFT);
  text("Excitement Radar", 30,775); 
  
  // Any other static items? Like static buttons (appearance doesn't change) go here.
 
}

// update default changes for each time unit
void updateDefaultChanges()
{
    // Update time
    for (int i = 0; i < views.length; i++)
      views[i].updateTime();
    
    
    //views[curView].updateTime();
    
   // Update main view
   // Update all balls
  // Cools down slower for monthly and daily views
  boolean doUpdate = true;
   switch(curView)
   {
      case 0:// day // updates every day
       if (views[0].getCurHour() != 0)
       {
           doUpdate = false;
       }
       else
       {
        // Update total excitement level
         updateTotalExcitement();
        
       }
       break;
      
      case 1: // month : update twice a month
      if (!(views[1].getCurDay() == 1 || views[1].getCurDay() == 15))
       {
           doUpdate = false;
       }
       if(views[1].getCurDay() == 1)
       {
        // Update total excitement level
       updateTotalExcitement(); 
       
       }
        break;
      case 2: // year: updates every month
      if(views[2].getCurMonth() == 1)
       {
        // Update total excitement level
       updateTotalExcitement();
      
       }
      
        break;
       
   }
   if(doUpdate)
   {
    Iterator i = g_balls.entrySet().iterator();  // Get an iterator
    while (i.hasNext()) 
    {
      Map.Entry me = (Map.Entry)i.next();
      Ball b = (Ball) me.getValue();
      b.update();  
    } 
   }
    
    
     
}

void updateTotalExcitement()
{
  g_totalExcitementLevels.add(g_totalExcitement);
  g_totalExcitement = 0; 
    
}
void drawTotalExcitement()
{
  if(g_totalExcitementLevels.size() == 0)
    return;
  int start = (Integer) g_totalExcitementLevels.get(0);
  int baselineX = 750;
  int baselineY =720;
  int displacement = 400/views[curView].getTotalSliderTime() + 400%views[curView].getTotalSliderTime();
  if(displacement >= 400)
    displacement = 1;
  int cur_displacement = 0;
  for(int i = 1; i < g_totalExcitementLevels.size(); i++)
  {
    int second = (Integer)g_totalExcitementLevels.get(i);
      // connect first to second
      int x1 = baselineX + cur_displacement;
      int x2 = x1 + displacement;
      
       int start_t=1, second_t=1; 
      if(curView == 0)
      {
       start_t = start*5;
      second_t = second*5;  
      }
      else if(curView == 1)
      {
        start_t = start/10;
      second_t = second/10; 
      }
      else if(curView == 2)
      {
        start_t = start/100;
      second_t = second/100; 
      }
      if(start_t > 200)
        start_t = 200;
      if(second_t > 200)
        second_t = 200;
     
      int y1 = baselineY - start_t;
      int y2 = baselineY - second_t;
      
        
      line(x1,y1,x2,y2);
      cur_displacement += displacement;
      start = second;
          
  }
  
}
// Updates backend with new information based on current time
void updateNewInfo()
{
   // Get email for this time period and update accordingly   
   
   ArrayList e = getNewEmails();
   //println("Size of new emails: " + e.size());
   // We've got the new emails for this time period. Add it in. 
   // But we should stagger it out into sub frames.
   // Add emails to existing balls or create new balls
   g_newEmails = null;
   g_newEmails = e;
   staggerEmail();
    
}

void staggerEmail()
{
  if(g_newEmails.size() == 0)
    return;
    
    int curSubFrame = angle_count%updateSpeed;
    // Find total number of new emails
    // Update only total / 30 each time
    int eachUpdate = g_newEmails.size() / updateSpeed;
    if(eachUpdate == 0)
      eachUpdate = 1;
      // TODO: Note: this stagger will update all remaining at the end, and doesn't stagger the modulus
      // E.g.: if there's 40, it'll update 1 per frame and 11 at frame 29.
    if(angle_count != 29)
    {
      // update only a subset
      int count = 0;
      int i;
      for (i =curSubFrame * eachUpdate ; i< g_newEmails.size() && count < eachUpdate; i++)
     {
       Email e_id = (Email) g_newEmails.get(i);
       int id = e_id.getThreadId();
       //println("adding email: "+ i + " id: "+ id + " Subject: " + e_id.getSubject());
       addEmailToBall((Email) g_newEmails.get(i));
       count++;
     }  
     if(i >= g_newEmails.size())
       g_newEmails = new ArrayList<Email>();
    }
    else
    {
       // update all remaining
      int i;
      for (i =curSubFrame * eachUpdate; i< g_newEmails.size() ; i++)
     {
       Email e_id = (Email) g_newEmails.get(i);
       int id = e_id.getThreadId();
       //println("29: adding email: "+ i + " id: "+ id + " Subject: " + e_id.getSubject());
       addEmailToBall((Email) g_newEmails.get(i));
       
     } 
     if(i >= g_newEmails.size())
       g_newEmails = new ArrayList<Email>();
    }
    
}

void addEmailToBall(Email e)
{
  // Check if this email is in a ball
  // If yes, add to that ball
  // If no, create new ball and add to g_balls
  if(g_balls.get(e.getThreadId()) != null)
  {
      // Add to this ball
      Ball b = (Ball) g_balls.get(e.getThreadId());
      b.addEmail(e);
  }
  else
  {
     // Create new ball 
     int id = e.getThreadId();
     Ball b = new Ball(getCurrentAngle(), id);
     b.addEmail(e);
     g_balls.put(id, b);
     
  }
    
    
    
}

ArrayList getNewEmails()
{
   // How to translate current time to months from start?
   // TODO: We'll do for year first
   ArrayList result = new ArrayList(); 
      
   // Get emails from current year and time
   // What's an efficient way to get emails? use curEmailPtr
   // Check if the next email is in this year / month
   // If later than this time, then return empty list, else progress pointer and return list
   
   int failsafe = 0; // just in case we get into an endless loop for some reason
   // Assume we dont have 1200 emails each time period
  
   while(failsafe < 1200)
   {
     //println("curEmailPtr: " + curEmailPtr + " g_emails: " + g_emails.size());
      if(curEmailPtr >= g_emails.size())
        return result;
        
      Email e = (Email) g_emails.get(curEmailPtr);
      if(!getNextEmail(e))
      {
         return result;
      }
      g_totalExcitement += e.getExcitementLevel(); 
       println("Adding email");
        result.add(e);
        curEmailPtr++;
      
     failsafe++;
   }
   return result;
}
boolean getNextEmail(Email e)
{  
  //println ("e year: " + e.getYear() + " view: " + views[curView].getCurYear());
 // println ("e month: " + e.getMonth() + " view: " + views[curView].getCurMonth());
 // println ("e day: " + e.getDay() + " view: " + views[curView].getCurDay());
  //println ("e hour: " + e.getHour() + " view: " + views[curView].getCurHour());
       switch(curView)
       {
          case 0: // Day
            // Time unit for day is hours
            // Compare Hour (Year, month, day, hour must be same)   
           if(e.getYear() == views[curView].getCurYear() && 
           e.getMonth() == views[curView].getCurMonth() &&
           e.getDay() == views[curView].getCurDay() &&
           e.getHour() == views[curView].getCurHour())
           {
              return true; 
           }            
            break;
          
          case 2: // Year
            // Find # of months passed since start 
            // Year, month must be same
           if(e.getYear() == views[curView].getCurYear() && 
           e.getMonth() == views[curView].getCurMonth())
           {
              return true; 
           }
                 
            break;
          
          case 1: // Month  
          default:
            // Time units for month is days
           // Year, Month, day must be same 
           if(e.getYear() == views[curView].getCurYear() && 
           e.getMonth() == views[curView].getCurMonth() &&
           e.getDay() == views[curView].getCurDay())
           {
              return true; 
           }     
       }     
       
      return false; 

}
void updateSliderTitle(boolean doAll)
{
 int v = (int) cp5.getController("Time").getValue();
       // Show date in slider value label
        int[] this_datetime = getSliderDatetime(v);
        String slider_title;
        switch(curView)
       {
          case 0: // Day
            // Time unit for day is hours
            // Show Year, Month, Day, Hour
            slider_title = this_datetime[0] + " " + getMonthOfYear(this_datetime[1]) + ", " + this_datetime[2] ;          
            break;
          
          case 2: // Year
            // Show Year, Month 
            slider_title = ""+this_datetime[2];        
            break;
          
          case 1: // Month  
          default:
            // Time units for month is days
            // Show Day, Month, Year      
            slider_title = getMonthOfYear(this_datetime[1]) + ", " + this_datetime[2]; 
       }        
        cp5.getController("Time").setValueLabel(slider_title); 
        if(doAll)
        {
           g_yearStart = this_datetime[2];
           g_monthStart = this_datetime[1];
           g_dayStart = this_datetime[0];
           g_hourStart = 0;
           curEmailPtr = 0;
             
          views[curView].setCurSliderTime(v);
          
           // reset email pointer
           for(int i  = 0; i < g_emails.size(); i++)
           {
             
              Email e = g_emails.get(curEmailPtr);
              //println("year: " + e.getYear() + " year start = " + g_yearStart);
              //println("month: " + e.getMonth() + " month start = " + g_monthStart);
              //println("day: " + e.getDay() + "day start = " + g_dayStart);
             if (e.getYear() < g_yearStart)
              {
                 curEmailPtr++;
                 continue;
              }
             if (e.getMonth() < g_monthStart)
              {
                 curEmailPtr++;
                 continue;
              }
            if (e.getDay() < g_dayStart)
              {
                 curEmailPtr++;
                 continue;
              }    
              break;
           }        
        }
  
   
}
void reset()
{
  //println("ball reset");
  isPaused = true;
  isForward = true;
  isSubmenuOpen = true;
  
  angle_count = 0;

   g_totalExcitement = 0;
   g_totalExcitementLevels = new ArrayList();
  g_balls = new HashMap();
  g_newEmails = new ArrayList<Email>();
  g_subMenuBall = null;
   //int viewType, int currentYear, int currentMonth, int currentDay, int currentHour
   int curSliderTime0 = views[0].getCurSliderTime();// preserve slider time
  int curSliderTime1 = views[1].getCurSliderTime();// preserve slider time
 int curSliderTime2 = views[2].getCurSliderTime();// preserve slider time 
   views = new View[3];
  views[0] = new View("Daily View", 0, g_yearStart, g_monthStart, g_dayStart, -1); 
  views[1] = new View("Monthly View", 1, g_yearStart, g_monthStart, 1, 0);  
  views[2] = new View("Yearly View", 2, g_yearStart, 0, 1, 0);
  
  setTotalTimeForViews();
  
  views[0].setCurSliderTime(curSliderTime0);
  views[1].setCurSliderTime(curSliderTime1);
  views[2].setCurSliderTime(curSliderTime2);
}

float getCurrentAngle()
{
    int time;// = views[curView].getTime();
    int total_time = views[curView].getUnitsPerRevolution();
    
    switch(curView)
   {
      case 0: // day
       time =  views[curView].getCurHour();
       break;
      case 1:
     time =  views[curView].getCurDay();
       break;
      
      case 2:
     time =  views[curView].getCurMonth();
       break; 
       default:
         time =  views[curView].getCurDay();
   }
   
    // We update info every 30 frames but animate dial every frame. 
    float angle;
    
    float last_angle = (time % total_time) * TWO_PI / total_time;
    float angle_diff =  angle_count%updateSpeed  * TWO_PI / total_time / updateSpeed;
   float cur_angle = last_angle + angle_diff;
   // update the speed right now if angle_diff == 0;
   if(pending_updateSpeed != 0)
   {
     //println("Setting update speed: "+ pending_updateSpeed);
      updateSpeed = pending_updateSpeed;
     pending_updateSpeed = 0; 
   }
   
  return cur_angle; 
}

// Redraws the main view
void redrawMainView()
{
  // Redraw Dial
   //int time = views[curView].getTime();
    int total_time = views[curView].getUnitsPerRevolution();
   
   float cur_angle = getCurrentAngle(); 
   int cur_unit;
   switch(curView)
   {
      case 0: // day
       cur_unit =  views[curView].getCurHour();
       if (cur_unit == 0)
         cur_unit = 1;
       break;
      case 1:
     cur_unit =  views[curView].getCurDay();
     if (cur_unit == 0)
       cur_unit = 1;
       break;
      
      case 2:
     cur_unit =  views[curView].getCurMonth();
     if (cur_unit == 0)
       cur_unit = 1;
       break; 
       default:
         cur_unit =  views[curView].getCurDay();
   }
   int time = cur_unit;
    /*
    if(isPaused)
    {
      // Go to last-known time.
      angle = last_angle;    
    }
    else
    {*/
      // Add intermediate frames
      float angle = cur_angle;
    //}
    
    
  // There's an angle diff, create the residue of the sweep, ie a white arc with transparency
  // Arc : last angle to current angle
  fill(#ffffff, 120);
  arc(dotx,doty, radius*2, radius*2, -HALF_PI, cur_angle- HALF_PI, PIE);
    
  //println("angle: " + angle);
  
  stroke(#00EE00);
  strokeWeight(2);
  fill(#00EE00);
  //line(dotx,doty,dotx + radius*sin(angle), doty -  radius * cos(angle));
   // draw time text at end of dial
   textFont(g_font, 14);
   if(cur_unit>0)
     text(cur_unit, dotx + (radius+18)*sin(angle), doty -  (radius+18) * cos(angle) );   
   
   // Redraw Time control buttons
   /*
     1) Play/Pause
     2) Forward/Backword
   */
   
   if(isPaused)
   {
      // Set play action
      image(playImg, play_btnx, play_btny);
   }
   else
   {
       // Set pause action
      image(pauseImg, play_btnx, play_btny);
   }
  // if(isForward)
    // println("isForward: " + isForward);
   /*if(isForward)
   {
     // Set forward on, back off
      image(backImg, back_btnx, back_btny);
      image(forwardImgOn, forward_btnx, forward_btny);
   }
   else
   {
     // Set forward off, back on
      image(backImgOn, back_btnx, back_btny);
      image(forwardImg, forward_btnx, forward_btny);
   }*/
   
   // Redraw current DateTime.
   String title, slider_title;
   switch(curView)
       {
          case 0: // Day
            // Time unit for day is hours
            // Show Year, Month, Day, Hour
            slider_title = views[curView].getCurDay() + " " + getMonthOfYear(views[curView].getCurMonth()) + ", " + views[curView].getCurYear() ;
           title = views[curView].getCurDay() + " " + getMonthOfYear(views[curView].getCurMonth()) + ", " + views[curView].getCurYear() + " " + formatHourDisplay(views[curView].getCurHour()); 
           setTitle(title);
           
            break;
          
          case 2: // Year
            // Show Year, Month 
            slider_title = ""+views[curView].getCurYear();
           title =getMonthOfYear(views[curView].getCurMonth()) + ", " + views[curView].getCurYear(); 
           setTitle( title);                           
           
            break;
          
          case 1: // Month  
          default:
            // Time units for month is days
            // Show Day, Month, Year
            int day = views[curView].getCurDay();      
            if(day == 0)
              day = 1;
            slider_title = getMonthOfYear(views[curView].getCurMonth()) + ", " + views[curView].getCurYear();
           title =day + " " + getMonthOfYear(views[curView].getCurMonth()) + ", " + views[curView].getCurYear() ;        
           setTitle(title);
           
   
       }
   if(!isPaused)
   {
     //println("slider time: "+ views[curView].getCurSliderTime());
     cp5.getController("Time").setValue(views[curView].getCurSliderTime());
     cp5.getController("Time").setValueLabel(slider_title); 
   }
   // Redraw all balls
   
    Iterator i = g_balls.entrySet().iterator();  // Get an iterator
    while (i.hasNext()) 
    {
      Map.Entry me = (Map.Entry)i.next();
      Ball b = (Ball)me.getValue();
      b.drawMe();  
    }
    
    // Redraw Chart
    drawTotalExcitement();
}



boolean isLeapYear(int year)
{
  return !(year % 4 == 0);
}

int getNumDaysInMonth(int month, int year)
{
   switch(month)
         {
            case 1: // Jan
            case 3: 
            case 5:
            case 7:
            case 8: 
            case 10:
            case 12:
              return 31;
                    
            case 4:
            case 6:
            case 9:
            case 11:
              return 30;
            case 2:
            if(isLeapYear(year))
            {
              return 29;            
            }
            else
            {
              return 28;                        
            }
  
               
            default:
              return 0;
               
         } 
}

int[] getSliderDatetime(int time)
{
  println(time);
  int this_time = time-1;
  
  Email e1 = g_emails.get(0);
  int y1 = e1.getYear();
  int m1 = e1.getMonth();
  int d1 = e1.getDay();
  
 
  int[] result = new int[3]; // 0: day, 1: month, 2: year
  switch(curView)
  {
     case 0: // day
       
       // cover first month
       int first_month = getNumDaysInMonth(m1,y1) - d1;
       if(this_time < first_month)
       {
          result[0] = d1+this_time;
          result[1] = m1;
          result[2] = y1; 
       }
       else
       {
         
         result[0] = 0;
          result[1] = m1+1;
          result[2] = y1;
         this_time -= first_month;
        
         while(this_time >0)
         {
          
           int this_month =getNumDaysInMonth(result[1],result[2]); 
           if(this_time < this_month)
           {
              result[0] = this_time;
              this_time = 0;
              
           }
           else
           {
              this_time -= this_month;
             result[1] += 1;
            if(result[1] > 12)
           {
              result[1] -= 12;
              result[2] += 1;
           } 
           }
         }  
       }
       
       break;
     case 1: // month
       result[2] = y1 + this_time/12;
       result[0] = 0;
       result[1]= m1 + this_time % 12;
       if(result[1] > 12)
       {
          result[2] += 1;
          result[1] -= 12; 
       }
       break;
     case 2: // year
       result[2] = y1 + this_time;
       result[0] = 0;
       result[1]= 0;
       break;
  }
  return result;
}

void setTotalTimeForViews()
{
  // sets total time units based on curView and g_emails, up to day accuracy for all views 
  Email e1 = g_emails.get(0);
  Email e2 = g_emails.get(g_emails.size()-1);
  int total_time = 0;
  int y1 = e1.getYear();
  int y2 = e2.getYear();
  int m1 = e1.getMonth();
  int m2 = e2.getMonth();
  int d1 = e1.getDay();
  int d2 = e2.getDay();
  
  
  
  // Day view: start on the day
  // Add number of days in partial of y1 and y2
  // Add number of days in between y1+1 and y2-1
  // Add days from m1 to end of year
  for (int i = m1; i <= 12; i++)
  {
      total_time += getNumDaysInMonth(m1, y1);
  }
  total_time -= d1; // minus of days already passed
  
  for (int i = 1; i <= m2; i++)
  {
      total_time += getNumDaysInMonth(i, y2);
  }
  total_time += d2; // add days not passed
  
  for(int i = y1+1; i<y2; i++)
  {
     if(isLeapYear(i))
      total_time += 366;
     else
      total_time += 365; 
  }
  
  views[0].setTotalSliderTime(total_time);
  
  // Month view: start on the month
  total_time = (y2-y1)  * 12 + (12 - m1) + m2; 
  //println("total month slider: " + total_time);
  views[1].setTotalSliderTime(total_time);
  
  // Year view: start on the year
  total_time = y2-y1 ; 
  //println("total year slider: " + total_time);
  if(total_time == 0)
    total_time = 1;
  views[2].setTotalSliderTime(total_time);
  
  
}

String formatHourDisplay(int i)
{
  if(i<0)
    return "00:00";
  if(i<10)
    return "0"+i+":00";
  else
    return ""+i+":00";
}
String getMonthOfYear(int i)
{
  switch(i)
  {
     case 1: 
        return "January";
     case 2:
       return "February";
     case 3:
       return "March";
     case 4:
       return "April";
     case 5:
       return "May";
     case 6:
       return "June";
     case 7:
       return "July";
     case 8:
       return "August";
     case 9:
       return "September";
     case 10:
       return "October";
     case 11:
       return "November";
     case 12:
       return "December";
     default:
     return "January";  
  }  
}

void selectNextBall()
{
  
}

void keyPressed()
{
  if(key == CODED)
  {
    if(g_balls == null)
      return;
    if(keyCode == UP)
    {
        // Get an iterator
      boolean found = false;
      Ball b = null;
      Ball head = null;
      int i = 0;
      for(Iterator it = g_balls.entrySet().iterator(); it.hasNext();)
      {
        Map.Entry me = (Map.Entry)it.next();
        b = (Ball)me.getValue();
        if(b.getVisible())
        {
          if(i == 0)
          {
            head = b;
          }
          if(!isSubmenuOpen)
          {
            break;
          }
          else
          {
            if(found)
            {
              break;
            }
            else if(b == g_subMenuBall)
            {
              found = true;
            }
          }
          i++;
        }
      }
      if(b == g_subMenuBall)
      {
        b = head;
      }
      if(b != null)
      {
        closeSubmenu();
        g_subMenuBall = b;
        b.select();
        openSubmenu();
      }
    }
  }
}

void mouseClicked()
{
  
  // Checks if play, back, forward button is pressed
  println("Clicking mouse button");
  // Check play
  if(mouseX>play_btnx && mouseX < play_btnx+58 && mouseY>play_btny && mouseY <play_btny+58){
    //println("The mouse is pressed and over the play button");
    isPaused = !isPaused;
    //do stuff
  }
  else // Check each ball if it's clicked
  {
    Iterator i = g_balls.entrySet().iterator();  // Get an iterator
    Boolean foundBall = false;
    while (i.hasNext())
    {
      Map.Entry me = (Map.Entry)i.next();
      Ball b = (Ball) me.getValue();
      if(b.getVisible())
      {
        int b_x = b.getX();
        int b_y = b.getY();
        int b_radius = b.getDiameter() / 2 - 3; // Force users to click more to the center for more accuracy
        if(mouseX>b_x - b_radius && mouseX < b_x + b_radius && mouseY>b_y - b_radius && mouseY < b_y + b_radius)
        {
          if(g_subMenuBall != null)
          {
            g_subMenuBall.deselect();
          }
          g_subMenuBall = b;
          b.select();
          openSubmenu();
          foundBall = true;
          break; // Only 1 ball is to be clicked each time
          //do stuff
        }
      }
    }
    // Clear the submenu if we click out
    if(!foundBall)
    {
      closeSubmenu();
    }
    
  }
  if(isPaused)
  {
    // Set play action
    image(playImg, play_btnx, play_btny);
  }
  else
  {
    // Set pause action
    image(pauseImg, play_btnx, play_btny);
  }
  
}

void openSubmenu()
{
  isSubmenuOpen = true;
}
void closeSubmenu()
{
  if(g_submenu != null)
  {
    g_submenu.setText("");
  }
  if(g_subMenuBall != null)
  {
    g_subMenuBall.deselect();
    g_subMenuBall = null;
  }
  isSubmenuOpen = false;
}

// Updates and redraws sub menu
void updateSubMenu()
{
   // Redraw current sub menu
   if (g_subMenuBall == null || !isSubmenuOpen)
     return;
   if (!g_subMenuBall.getVisible())
   {
     closeSubmenu();
     return;
   }
     
   // Show: Each email (Sender, Date, Subject, Body)
   String text = g_subMenuBall.getEmailThread();
   
   // Fix for single-line-full-of-spaces issue
   text = text.replaceAll("\r", "");
   //text = text.replaceAll("  ", " ");
   text = text.replaceAll("\n\n", "\n");
   text = text.replaceAll("\n +", "\n");
   text = text.replaceAll(" +\n", "\n");
   
   g_submenu.setText(text);
}

// Updates any aninimation that is running
void updateAnimation()
{
  // Clear out all new emails for this period
  
  staggerEmail();
}

void setTitle(String text)
{
  fill(borderColor);
  textFont(g_font, 32);
  textAlign(CENTER, BOTTOM);
  text(text, 650,60);      
}
