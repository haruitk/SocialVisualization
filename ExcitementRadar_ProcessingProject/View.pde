class View
{
  // viewType: 0: day, 1: month, 2: year
  // currentMonth: starts at 1
  // currentDay: starts at 1
  // currentYear: starts at 1
   int time, total_slider_time, cur_slider_time, unitsPerRevolution, currentYear, currentMonth, currentDay, currentHour, viewType; 
   String title;
   boolean isStepForward;
   
   View(String mytitle, int viewType, int currentYear, int currentMonth, int currentDay, int currentHour)
   {
      time=0;
     title = mytitle; 
     isStepForward = true;
     unitsPerRevolution = 0;// deprecated
     this.viewType = viewType;
     this.currentYear = currentYear;
     this.currentMonth = currentMonth;
     this.currentDay = currentDay;
     this.currentHour = currentHour;
     this.total_slider_time = 0;
     this.cur_slider_time = 1;
   }
   int getCurSliderTime()
   {
     return this.cur_slider_time;
   }
   void setCurSliderTime(int time)
   {
     this.cur_slider_time = time;
   }
   void setTotalSliderTime(int total_slider_time)
   {
     this.total_slider_time = total_slider_time;
   }
   void updateTime()
   {
      if(isStepForward)
     {
        time++;
        switch(viewType)
        {
           case 0: // Day, increment hour
            currentHour++;            
            break;
           case 2: // Year
             currentMonth++;
             break;
           case 1: // Month
           default:
             currentDay++;
             break;
        }
        this.sanitizeTime(true);
     } 
     else
     {
       time--;
        switch(viewType)
        {
           case 0: // Day, increment hour
            currentHour--;            
            break;
           case 2: // Year
             currentMonth--;
             break;
           case 1: // Month
           default:
             currentDay--;
             break;
        }
        this.sanitizeTime(false);       
     }
   }
   
   int getTime()
   {
      return time; 
   }
   int getTotalSliderTime()
   {
      return this.total_slider_time; 
   }
   void sanitizeTime(boolean isForward)
   {
       if(isForward) 
       {
         if(currentHour > 23)
         {
             currentHour -= 24;
             currentDay += 1;
             if(viewType == 0) // day view
               this.cur_slider_time++;
         }
         switch(currentMonth)
         {
            case 1: // Jan
            case 3: 
            case 5:
            case 7:
            case 8: 
            case 10:
            case 12:
              if(currentDay > 31)
              {
                 currentDay -= 31;
                currentMonth += 1; 
                if(viewType == 1) // month view
                   this.cur_slider_time++;
              }
              break;         
            case 4:
            case 6:
            case 9:
            case 11:
              if(currentDay > 30)
              {
                 currentDay -= 30;
                currentMonth += 1;
               if(viewType == 1) // month view
                   this.cur_slider_time++; 
              }
              break;
            case 2:
            if(this.isLeapYear())
            {
              if(currentDay > 29)
                {
                   currentDay -= 29;
                  currentMonth += 1;
                 if(viewType == 1) // month view
                   this.cur_slider_time++; 
                }            
            }
            else
            {
              if(currentDay > 28)
                {
                   currentDay -= 28;
                  currentMonth += 1; 
                  if(viewType == 1) // month view
                   this.cur_slider_time++;
                }                        
            }
  
               break;
            default:
              ;
               
         }
          if(currentMonth > 12)
          {
             currentMonth -= 12;
            currentYear += 1;
           if(viewType == 2) // year view
                   this.cur_slider_time++; 
          }            
       }
       else // moves back by 1
       {
         if(currentHour < 0)
         {
             currentHour += 24;
             currentDay -= 1;
             if(viewType == 0) // day view
                   this.cur_slider_time--;
         }
        if(currentDay < 1)
        {
           //currentDay += 31;
          currentMonth -= 1; 
        }
          if(currentMonth <  1)
          {
             currentMonth += 12;
            currentYear -= 1;
           if(viewType == 1) // year view
                   this.cur_slider_time--; 
          }          
         switch(currentMonth)
         {
            case 1: // Jan
            case 3: 
            case 5:
            case 7:
            case 8: 
            case 10:
            case 12:
              if(currentDay < 1)
              {
                 currentDay = 31; 
                 if(viewType == 1) // month view
                   this.cur_slider_time--;
              }
              break;            
            case 4:
            case 6:
            case 9:
            case 11:
              if(currentDay < 1)
              {
                 currentDay = 30; 
                 if(viewType == 1) // month view
                   this.cur_slider_time--;
              }
              break;
            case 2:
            if(this.isLeapYear())
            {
              if(currentDay < 1)
              {
                 currentDay = 29; 
                 if(viewType == 1) // month view
                   this.cur_slider_time--;
              }         
            }
            else
            {
             if(currentDay < 1)
              {
                 currentDay = 28; 
                 if(viewType == 1) // month view
                   this.cur_slider_time--;
              }                      
            }
  
               break;
            default:
              ;
               
         }
        
       }
         
   }
   int getCurYear()
   {
      return this.currentYear; 
   }
   int getCurMonth()
   {
      return this.currentMonth; 
   }
   int getCurDay()
   {
      return this.currentDay; 
   }
   int getCurHour()
   {
      return this.currentHour; 
   }
   
   // Returns true if is leap year
   boolean isLeapYear()
   {
     return !(this.currentYear % 4 == 0) ;
   }
   int getUnitsPerRevolution()
   {
        switch(viewType)
        {
           case 0: // Day, return hours
            return 24;            
            
           case 2: // Year
             return 12;
             
           case 1: // Month
           default:
              switch(currentMonth)
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
                  if(this.isLeapYear())
                  {
                    return 29;       
                  }
                  else
                  {
                   return 28;                     
                  }
        
                     
                  default:
                    ;
                     
               }
             break;
        }
        
     return 1; 
   }
   
   String getTitle()
   {
      return title; 
   }
   
   void setTimeDirection(boolean isForward)
   {
     isStepForward = isForward;
   }
   
   boolean getTimeDirection()
   {
     return isStepForward;
   }
}
