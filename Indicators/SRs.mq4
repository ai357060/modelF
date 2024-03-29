#property strict
#property indicator_separate_window
//#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   5
#property indicator_minimum -3.5
#property indicator_maximum 3.5
#property indicator_level1 0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT

//--- plot Label1
#property indicator_label1  "M1"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "M2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

#property indicator_label3  "W1"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "W2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_DOT
#property indicator_width4  1

#property indicator_label5  "D1"
#property indicator_type5   DRAW_HISTOGRAM
#property indicator_color5  clrBlue
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1

//--- plot Label2
//#property indicator_label2  "Label2"
//#property indicator_type2   DRAW_HISTOGRAM
//#property indicator_color2  clrSaddleBrown
//#property indicator_style2  STYLE_SOLID
//#property indicator_width2  1
//--- plot Label3
//#property indicator_label3  "Label3"
//#property indicator_type3   DRAW_HISTOGRAM
//#property indicator_color3  Green
//#property indicator_style3  STYLE_SOLID
//#property indicator_width3  1
//--- indicator buffers
//double         SR_st[];
double         SR_break_showM1[];
double         SR_break_showM2[];
double         SR_break_showW1[];
double         SR_break_showW2[];
double         SR_break_showD1[];
//double         SR_stop[];
//extern ENUM_TIMEFRAMES Period1 = PERIOD_MN1;
//extern ENUM_TIMEFRAMES Period2 = PERIOD_W1;
//extern ENUM_TIMEFRAMES Period3 = PERIOD_M1;
extern color colorMN1 = clrRed;
extern color colorW1 = clrGreen;
extern color colorD1 = clrNONE ;

string      sObject;

//property indicator_chart_window


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   IndicatorShortName("SRs");
   SetIndexBuffer(0,SR_break_showM1);
   SetIndexBuffer(1,SR_break_showM2);
   SetIndexBuffer(2,SR_break_showW1);
   SetIndexBuffer(3,SR_break_showW2);
   SetIndexBuffer(4,SR_break_showD1);
//   SetIndexBuffer(2,SR_stop);

   sObject = "SRs"+Symbol();
   DeleteOwnObjects();  
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   DeleteOwnObjects();
}


void FindSRs(int drawperiod,int period,int srcolor,int slip)
{
   double RR;
   int iR;
//   double BB;
   int iB;
   int wB;
   bool isAllTime;
//   double TT;
   int iT;
   datetime starttime,breaktime;
   int limit = iBars(Symbol(),period);
   datetime endtime;   
   double SR_break[];
   ArrayResize(SR_break,limit,10);
   double slipvalue = slip * MarketInfo(Symbol(),MODE_POINT);
   int wd = 1;
   if (period==PERIOD_W1 && drawperiod==PERIOD_D1) wd = 2;
   if (period==PERIOD_MN1 && drawperiod==PERIOD_D1) wd = 3;
   if (period==PERIOD_MN1 && drawperiod==PERIOD_W1) wd = 2;
   ENUM_LINE_STYLE st = STYLE_DOT;
   if (period==PERIOD_W1 && drawperiod==PERIOD_D1) st = STYLE_DASHDOT;
   if (period==PERIOD_MN1 && drawperiod==PERIOD_D1) st = STYLE_DASHDOTDOT;
   if (period==PERIOD_MN1 && drawperiod==PERIOD_W1) st = STYLE_DASHDOT;
   for(int i=limit-1; i>0; i--)
   {
      //if (iBarShift(Symbol(),drawperiod,iTime(Symbol(),period,i)==-1))
      //   continue;
      if ((iClose(Symbol(),period,i)>=iClose(Symbol(),period,i-1)) && (iClose(Symbol(),period,i)>iClose(Symbol(),period,i+1)))
//      if ((iClose(Symbol(),period,i)>=iClose(Symbol(),period,i-1)) && (iClose(Symbol(),period,i)>iOpen(Symbol(),period,i)))
      {
         iR = i;
         RR = MathMax(iHigh(Symbol(),period,iR),iHigh(Symbol(),period,iR-1));
         iB = FindUpBreak(RR,iR,period);
         wB = willBreakDOWN(iR,iB,SR_break) -1 ;
         isAllTime = isItAllTimesHigh(RR,limit,iR,period);
         if (isAllTime || wB>0)
         {
//            SR_st[iR] = RR;
            SR_break[iB] = 1;
            iT = FindDownBreak(RR,iB,period);
            if (period!=PERIOD_D1) SR_break[iT] = -1;//
            if (iT>0)
               if (drawperiod!=period)
                  endtime = iTime(Symbol(),period,iT-1);//-1
               else   
                  endtime = iTime(Symbol(),period,iT);
            else   
               endtime = iTime(Symbol(),drawperiod,0);
            if (iB>0)
               if (drawperiod!=period)
                  breaktime = iTime(Symbol(),period,iB-1);
               else   
                  breaktime = iTime(Symbol(),period,iB);
            else   
               breaktime = iTime(Symbol(),drawperiod,0);
            if (isAllTime)
            {
               //starttime = iTime(Symbol(),Period(),iBarShift(Symbol(),Period(),iTime(Symbol(),period,iR),false));
               starttime = iTime(Symbol(),period,iR);
            }   
            else
            {
               //starttime = iTime(Symbol(),Period(),iBarShift(Symbol(),Period(),iTime(Symbol(),period,wB),false));
               starttime = iTime(Symbol(),period,wB);
            }   
            RectangleCreate(0,"RR1"+IntegerToString(period)+IntegerToString(iR),0,starttime,RR+slipvalue,breaktime,RR+slipvalue,srcolor,drawperiod,st,1);
            RectangleCreate(0,"RR2"+IntegerToString(period)+IntegerToString(iR),0,breaktime,RR+slipvalue,endtime,RR+slipvalue,srcolor,drawperiod,STYLE_SOLID,wd);
            int ii = iBarShift(Symbol(),Period(),breaktime);
            if (ii>0)
            {
               if (period==PERIOD_MN1)
                  SR_break_showM1[ii] = 3;
               else if (period==PERIOD_W1)
                  SR_break_showW1[ii] = 2;
               else //if (period==PERIOD_D1)
                  SR_break_showD1[ii] = 1;
                  
            }
//            ii = iBarShift(Symbol(),Period(),endtime);
//            if (ii>0)
//            {
//               if (period==PERIOD_MN1)
//                  SR_break_showM1[ii] = -3;
//               else if (period==PERIOD_W1)
//                  SR_break_showW1[ii] = -2;
//              else //if (period==PERIOD_D1)
//                  SR_break_showD1[ii] = -1;
//                 
//            }
               
         }   
            
      }   
      if ((iClose(Symbol(),period,i)<=iClose(Symbol(),period,i-1)) && (iClose(Symbol(),period,i)<iClose(Symbol(),period,i+1)))
//      if ((iClose(Symbol(),period,i)<=iClose(Symbol(),period,i-1)) && (iClose(Symbol(),period,i)<iOpen(Symbol(),period,i)))
      {
         iR = i;
         RR = MathMin(iLow(Symbol(),period,iR),iLow(Symbol(),period,iR-1));
         iB = FindDownBreak(RR,iR,period);
         wB =  willBreakUP(iR,iB,SR_break) -1;
         isAllTime = isItAllTimesLow(RR,limit,iR,period);
         if (isAllTime || wB>0) 
         {
//            SR_st[iR] = RR;
            SR_break[iB] = -1;
            iT = FindUpBreak(RR,iB,period);
            if (period!=PERIOD_D1) SR_break[iT] = 1;//
            if (iT>0)
               if (drawperiod!=period)
                  endtime = iTime(Symbol(),period,iT-1);//-1
               else   
                  endtime = iTime(Symbol(),period,iT);
            else   
               endtime = iTime(Symbol(),drawperiod,0);
            if (iB>0)
               if (drawperiod!=period)
                  breaktime = iTime(Symbol(),period,iB-1);
               else   
                  breaktime = iTime(Symbol(),period,iB);
            else   
               breaktime = iTime(Symbol(),drawperiod,0);
            if (isAllTime)
               starttime = iTime(Symbol(),period,iR);
            else   
               starttime = iTime(Symbol(),period,wB);
               
            RectangleCreate(0,"SS1"+IntegerToString(period)+IntegerToString(iR),0,starttime,RR+slipvalue,breaktime,RR+slipvalue,srcolor,drawperiod,STYLE_SOLID,wd);
            RectangleCreate(0,"SS2"+IntegerToString(period)+IntegerToString(iR),0,breaktime,RR+slipvalue,endtime,RR+slipvalue,srcolor,drawperiod,st,1);
            int ii = iBarShift(Symbol(),Period(),breaktime);
            if (ii>0)
            {
               if (period==PERIOD_MN1)
                  SR_break_showM1[ii] = -3;
               else if (period==PERIOD_W1)
                  SR_break_showW1[ii] = -2;
               else //if (period==PERIOD_D1)
                  SR_break_showD1[ii] = -1;
                  
            }
//            ii = iBarShift(Symbol(),Period(),endtime);
//            if (ii>0)
//            {
//               if (period==PERIOD_MN1)
//                  SR_break_showM1[ii] = 3;
//               else if (period==PERIOD_W1)
//                  SR_break_showW1[ii] = 2;
//              else //if (period==PERIOD_D1)
//                  SR_break_showD1[ii] = 1;
//                  
//            }
         }   
      }   
         
   }

}
bool isItAllTimesHigh(double RR,int limit, int j, int period)
{
   bool alltimehigh = True;
   int tries =1;
   for(int i=limit-1; i>j; i--)
   {
      if (iClose(Symbol(),period,i)> RR)
      {
         tries = tries - 1;
         if(tries<0)
         {
            alltimehigh = False;
            break;
         }   
      }   
   }
//   alltimehigh = True;
   return alltimehigh;
}

bool isItAllTimesLow(double RR,int limit, int j, int period)
{
   bool alltimelow = True;
   int tries =1;
   for(int i=limit-1; i>j; i--)
   {
      if (iClose(Symbol(),period,i)< RR)
      {
         tries = tries - 1;
         if(tries<0)
         {
            alltimelow = False;
            break;
         }   
      }   
   }
//   alltimelow = True;
   return alltimelow;
}


int willBreakDOWN(int iR,int iB, double &SR_break[])
{
   int will = 0;
   for(int i=iR-1; i>iB; i--)
   {
      if (SR_break[i]==-1)
      {
         will = i;
         break;
      }   
   }
   return will;
}
int willBreakUP(int iR,int iB, double &SR_break[])
{
   int will = 0;
   for(int i=iR-1; i>iB; i--)
   {
      if (SR_break[i]==1)
      {
         will = i;
         break;
      }   
   }
   return will;
}

int FindUpBreak(double RR,int j, int period)
{
   int RRBreak = 0;
   for(int i=j-1; i>=0; i--)
   {
      if (iOpen(Symbol(),period,i)> RR)
      {
         RRBreak = i+1;
         break;
      }   
   }
   return RRBreak;
}

int FindDownBreak(double RR,int j, int period)
{
   int RRBreak = 0;
   for(int i=j-1; i>=0; i--)
   {
      if (iOpen(Symbol(),period,i)< RR)
      {
         RRBreak = i+1;
         break;
      }   
   }
   return RRBreak;
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars;
   if (limit>1)
   {
      if (colorMN1!=clrNONE)
         FindSRs(Period(),PERIOD_MN1,colorMN1,0);
      if ((colorW1!=clrNONE) &&(Period()<=PERIOD_W1))
         FindSRs(Period(),PERIOD_W1,colorW1,0);
      if ((colorD1!=clrNONE) &&(Period()<=PERIOD_D1))
         FindSRs(Period(),PERIOD_D1,colorD1,0);
   }
   
   double pp;
   for(int i=limit-1; i>0; i--)
   {
      pp = SR_break_showM1[i];
      if (pp==3 || pp==-3)
         for(int j=i; j>=0; j--)
            SR_break_showM2[j] = pp;
      pp = SR_break_showW1[i];
      if (pp==2 || pp==-2)
         for(int j=i; j>=0; j--)
            SR_break_showW2[j] = pp;
   } 
   //SR_break_showM2[1] = 4.0;

   
   return(rates_total);
  }
  
bool RectangleCreate(const long            chart_ID=0,        // chart's ID 
                     string                name="Rectangle",  // rectangle name 
                     const int             sub_window=0,      // subwindow index  
                     datetime              time1=0,           // first point time 
                     double                price1=0,          // first point price 
                     datetime              time2=0,           // second point time 
                     double                price2=0,          // second point price 
                     const color           clr=clrRed,        // rectangle color 
                     int                   timeframe=OBJ_PERIOD_D1,
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // style of rectangle lines 
                     const int             width=1,           // width of rectangle lines 
                     const bool            fill=false,        // filling rectangle with color 
                     const bool            back=false,        // in the background 
                     const bool            selection=false,    // highlight to move 
                     const bool            hidden=false,       // hidden in the object list 
                     const long            z_order=0)         // priority for mouse click 
                     
{ 
//--- set anchor points' coordinates if they are not set 
//   ChangeRectangleEmptyPoints(time1,price1,time2,price2); 
//--- reset the error value 
   ResetLastError(); 
//--- create a rectangle by the given coordinates 
   name = sObject+name;
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a rectangle! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set rectangle color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set the style of rectangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set width of the rectangle lines 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- enable (true) or disable (false) the mode of filling the rectangle 
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of highlighting the rectangle for moving 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   if (timeframe== PERIOD_H4) timeframe =  OBJ_PERIOD_H4;
   else if (timeframe== PERIOD_D1) timeframe =  OBJ_PERIOD_D1;
   else if (timeframe== PERIOD_W1) timeframe =  OBJ_PERIOD_W1;
   else if (timeframe== PERIOD_MN1) timeframe =  OBJ_PERIOD_MN1;
   else timeframe =  OBJ_PERIOD_D1;
   ObjectSetInteger(chart_ID,name,OBJPROP_TIMEFRAMES,timeframe); 
   
//--- successful execution 
   return(true);   
}

void DeleteOwnObjects()
{
   int i=0;
   while (i <= ObjectsTotal()) {
      if (StringFind(ObjectName(i), sObject) >= 0) ObjectDelete(ObjectName(i));
      else
      i++;
   }
   return;
}
  
//+------------------------------------------------------------------+
