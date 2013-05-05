class Email
{
  // same id means the email is in the same thread
  // year, month, day starts at 1.
  // hour starts at 0;
   int year, month, day, hour, thread_id, excitement_level;
   String sender, subject, body, datetime, keyword;
   
   Email(int id, int y, int m, int d, int h, int excitement_level, String this_sender, String this_subject, String this_body, String this_datetime, String keyword)
   {
     thread_id = id;
      year = y;
      month = m; 
      day = d;
      hour = h;
      this.excitement_level = excitement_level;
      sender = this_sender;
      subject = this_subject;
      body = this_body;
      datetime= this_datetime; 
      this.keyword = keyword;
   }
   int getYear()
   {
      return year; 
   }
   int getMonth()
   {
      return month; 
   }
   int getDay()
   {
      return day; 
   }
   int getHour()
   {
      return hour; 
   }
   int getThreadId()
   {
      return thread_id; 
   }
   int getExcitementLevel()
   {
      return excitement_level; 
   }
   String getSender()
   {
     return sender;
   }
   String getSubject()
   {
     return subject;
   }
   String getDatetime()
   {
     return datetime;
   }
   String getBody()
   {
     return body;
   }
   String getKeyword()
   {
      return keyword; 
   }
}
