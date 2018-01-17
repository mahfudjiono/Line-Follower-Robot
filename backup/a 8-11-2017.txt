/*****************************************************
Project : Line Follower Source Code Development
Version : Pzr 2.10
Date    : 04/01/2016
Author  : Tim Robot UM
Company : RDF Corporations
Comments: Source code development for LF-UM team, Gunakan secara bijak!
Dengan Ketentuan Sbb:
1. Jangan sebarkan source code ini kepada selain anggota team LF-UM.
2. Anggota yang sudah mendapatkan source code ini harus benar-benar bersedia
   untuk loyal terhadap team dan mampu memberikan kontribusi terhadap pengembangan
   LF-UM.
3. Melanggar ketentuan dosa lho rek.

Chip type               : ATmega32
Program type            : Application
AVR Core Clock frequency: 16.000000 MHz
Memory model            : Small
External RAM size       : 0
Data Stack size         : 512
*****************************************************/

#include <mega32.h>
#include <delay.h>
#include <stdio.h>
#include <alcd.h>
#define ADC_VREF_TYPE 0x20 
#define s1              PINC.0 //kanan1       
#define s2              PINC.2 //kiri2
#define s3              PINC.3 //kiri1
#define s4              PINC.4 //bawah
#define s5              PINC.1 //kanan2
#define s6              PINC.5 //atas
#define led             PORTD.7
#define R               PORTC.6       
#define L               PORTC.7
#define lmp             PORTB.3
#define kiju            OCR1B  
#define kidur           PORTD.3
#define kadur           PORTD.6
#define kaju            OCR1A  
#define input           PIND.0
#define output          PORTD.1

eeprom unsigned char esensitive[14];
eeprom unsigned char espeed[101];
eeprom unsigned char espeed1[101];
eeprom unsigned char etimer[101];
eeprom unsigned char eplan[21]; 
eeprom unsigned char eread[21];  
eeprom unsigned char ecut[101];
eeprom unsigned char ecut1[101];
eeprom unsigned char edel[101];
eeprom unsigned char eencomp=0;
eeprom unsigned char emode=0;
eeprom unsigned char emodekanan=0;
eeprom unsigned char epulsa=5;
eeprom unsigned char ekp=10;
eeprom unsigned char ekd=100;
eeprom unsigned char eki=0;
eeprom unsigned char elc=120;
eeprom unsigned char elc1=0;
eeprom unsigned char evc=120;
eeprom unsigned char emax1=100;

bit aktif=0,lock;                            
int rpwm,lpwm,max1,m,lc,vc,I,PV,error,lasterror,encomp,lc1,xcc;                                                
unsigned char kp,kd,ki,pulsa,batas=100;                          
unsigned char timer[101],speed[101],speed1[101],count2,start,time[101],cacah,cc,plan[21],read[21];                                                          
unsigned char SP=0,mode,cut[101],cut1[101],counting,protec,del[101],tunda,modekanan;                                                                           
unsigned char sensitive[14],in,adc,sam,samping,sam1,samping1,hight[14],low[14],scan,inv,invers;          
unsigned int dep,depan,sen,sm;  
int pass; 
char buff[33],bufff[33];
int pilih_start=0;
int pilih_cp=0;

void loading(){
int load;
for(load=0;load<=15;load++){
lcd_gotoxy(load,1);
lcd_putchar(0x5f);delay_ms(80);
lcd_putchar(0xff);delay_ms(80);
}
lcd_clear();
}

void saved(){
 lcd_clear();
 lcd_gotoxy(0,0);
 lcd_putsf("DONE SAVE!");delay_ms(300);
 lmp=1;
 lcd_clear();
}

//-------------timer0 interrupt overflow--------//
interrupt [TIM0_OVF] void timer0_ovf_isr(void)
{
if(aktif==0&&cacah<timer[start]&&mode==1){
if(++cc>=pulsa){
cacah++;cc=0;}
}
}

void rumus_pid()
{
if (error!=0){I=I+error;}
else{I=0;}
rpwm=(int)((max1+(error*kp))+((error-lasterror)*kd)+((ki*I)/35)); //dibalik
lpwm=(int)((max1+(-error*kp))-((error-lasterror)*kd)-((ki*I)/35)); //dibalik
//sudah saya balik
lasterror=error;
}
//-------------global fungsi--------//
void scansensor();
//-------------fungsi pembacaan adc--------//
unsigned char read_adc(unsigned char adc_input)
{
ADMUX=ADC_VREF_TYPE & 0xff;
ADMUX=adc_input | (ADC_VREF_TYPE & 0xff);
delay_us(10);  
ADCSRA|=0x40;
while ((ADCSRA & 0x10)==0);
ADCSRA|=0x10;
return ADCH;
}

//-------------fungsi motor controller--------//
void motor(int pwmkiri,int pwmkanan){ 
if (pwmkiri>255)pwmkiri=255;
 if (pwmkiri<-255)pwmkiri=(-255);
 if (pwmkanan>255)pwmkanan=255;
 if (pwmkanan<-255)pwmkanan=(-255); 

 if (lpwm>255)lpwm=255;
 if (lpwm<-255)lpwm=(-255);
 if (rpwm>255)rpwm=255;
 if (rpwm<-255)rpwm=(-255); 
 if (pwmkanan<0){
 kadur=1;
 kaju=255+pwmkanan;
 }
 if (pwmkiri<0){
 kidur=1;
 kiju=255+pwmkiri;
 } 
 if (pwmkanan>=0){
 kadur=0;
 kaju=pwmkanan;
 }
 if (pwmkiri>=0){
 kidur=0;
 kiju=pwmkiri;
 } 
}

//-------------fungsi enable pwm internal--------// 
void pwm_on()
{
TCCR1A=0xA1;
TCCR1B=0x0B;
}

//-------------fungsi disable pwm internal--------// 
void pwm_off()
{
TCCR1A=0x00;
TCCR1B=0x00;
}  

//-------------fungsi stop motor--------//
void stop(){
  motor(0,0);} 
  
//-------------fungsi mundur motor--------//  
void mundur(){                            
motor(-255,-255);}

//-------------fungsi belok kanan lancip--------//                
void kananlancip()
{int cp1,cp2;                                                      
        cp1=(255-lc)+(-255);  cp2=0+lc;             
        motor(cp2,cp1);                           
}

//-------------fungsi belok kiri lancip--------//  
void kirilancip()
{       int cp1,cp2;                                                      
        cp1=(255-lc)+(-255);  cp2=0+lc;             
        motor(cp1,cp2);                      
}

//-------------fungsi belok kanan counter--------//  
void kanan()
{    
        int cp1,cp2;
        lmp=1;
        tunda=del[start];                                                   
        cp1=(255-vc)+(-255);  cp2=0+lc;             
        motor(cp2,cp1);
        delay_ms(tunda);                      
}

//-------------fungsi belok kiri counter--------//  
void kiri()
{       
        int cp1,cp2;
        lmp=1; 
        tunda=del[start];                                                  
        cp1=(255-vc)+(-255);  cp2=0+lc;             
        motor(cp1,cp2);
        delay_ms(tunda);                       
}

//-------------fungsi kalibrasi sensor--------//  
void autoscan()  
{
int a,b;
unsigned char mata;
if(m==1){pwm_on();}
lcd_clear();
lcd_gotoxy(0,0);
lcd_putsf("     READY TO     ");
lcd_gotoxy(0,1);
lcd_putsf("   CALIBRATION  ");
delay_ms(500);
lcd_clear();
for(a=0;a<=6;a++){
        sensitive[a]=0;
        low[a]=255;
        hight[a]=0;
        }
for(a=0;a<1000;a++){
if(m==1){
motor(-128,128);
}
if(m==0){stop();
}
lcd_gotoxy(0,0);
lcd_putsf("Scaning sensor");
lcd_gotoxy(0,1);
sprintf(buff, "[ %d ][%i]",mata,a);
lcd_puts(buff);
L=1;
R=0;
for(b=0;b<=6;b++){
mata=read_adc(b+1);
if(mata<low[b]){
low[b]=mata;           
}
if(mata>hight[b]){
hight[b]=mata;        
}
delay_us(200);
}
L=0;
R=1;
for(b=7;b<=13;b++){
mata=read_adc(b-6);
if(mata<low[b]){
low[b]=mata;          
}
if(mata>hight[b]){
hight[b]=mata;        
}
delay_us(200);
} 
L=0; R=0;     
}
for(b=0;b<13;b++){
sensitive[b]=((hight[b]-low[b])/2)+low[b];     
};
lcd_clear();
lcd_gotoxy(0,0);
pwm_off();
stop();
lmp=1;
lcd_putsf("SAVE DATA...");
delay_ms(300);
for(b=0;b<13;b++){
esensitive[b]=sensitive[b];
}
loading();
lcd_gotoxy(0,1);
lcd_putsf("DONE!");
delay_ms(300);lmp=1;
lcd_clear();
}

//-------------fungsi seting PID--------//   
void pid()
{
int i;
i=0;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
if (!s5){i=i-1;}
if (i==(-1)){i=2;}
if (!s1){i=i+1;}
if (i==3){i=0;}
                if(i==0){
                        lcd_gotoxy(0,0);
                        lcd_putsf("Proporsional     ");
                        sprintf(buff,"Kp=%03d ", kp);
                        lcd_gotoxy(0,1);
                        lcd_puts(buff);
                        if(!s2){kp=kp+1;if (kp>255){kp=0;}}
                        if(!s3){kp=kp-1;if (kp<0){kp=255;}}
                        }
                if(i==1){
                        lcd_gotoxy(0,0);
                        lcd_putsf("Integratif ");
                        sprintf(buff,"Ki=%03d ", ki);
                        lcd_gotoxy(0,1);
                        lcd_puts(buff);
                        if(!s2){ki=ki+1;if(ki>255){ki=0;}}
                        if(!s3){ ki=ki-1;if (ki<0){ki=255;}}
                        }
                if(i==2){
                        lcd_gotoxy(0,0);
                        lcd_putsf("Derevatif    ");
                        sprintf(buff,"Kd=%03d ", kd);
                        lcd_gotoxy(0,1);
                        lcd_puts(buff);
                        if(!s2){
                        kd=kd+1;if (kd>255){kd=0;}}
                        if(!s3){kd=kd-1;if (kd<0){kd=255;}}
                        }
                if(!s4){
                if(kp!=ekp){ekp=kp;}
                if(ki!=eki){eki=ki;}
                if(kd!=ekd){ekd=kd;}
                saved();
                break;
                }
delay_ms(100);
}
}

//-------------fungsi setting timer--------//  
void waktu()
{int x;
x=0;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
lcd_putsf("    [SETTING]");
lcd_gotoxy(0,0);
sprintf(buff,"Timer %02d =%03d    ",x,timer[x]);
lcd_gotoxy(0,1);
lcd_puts(buff);
if(!s1){if(++x>batas){x=0;}lcd_clear();}
if(!s5){if(--x==-1){x=batas;}lcd_clear();}
if(!s2){timer[x]=timer[x]+1;}
if(!s3){timer[x]=timer[x]-1;}
if(!s4){lcd_clear();
for(count2=0;count2<=batas;count2++){etimer[count2]=timer[count2];}
                saved();
                break;}
delay_ms(150);
}
}

//-------------fungsi setting counter 1--------//
void pintas()
{int x;
x=1;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
lcd_putsf("    [SETTING]");
lcd_gotoxy(0,0);
sprintf(buff,"Count1 %02d ",x);
lcd_gotoxy(0,1);
lcd_puts(buff);
if(cut[x]==1){
lcd_gotoxy(11,1);
lcd_putsf("Lost   ");
}
if(cut[x]==2){
lcd_gotoxy(11,1);
lcd_putsf("Kanan  ");
}
if(cut[x]==3){
lcd_gotoxy(11,1);
lcd_putsf("Kiri   ");
}
if(cut[x]==4){
lcd_gotoxy(11,1);
lcd_putsf("Lost1  ");
}
if(cut[x]==5){
lcd_gotoxy(11,1);
lcd_putsf("Stop   ");
}
if(!s1){if(++x>batas){x=1;}lcd_clear();}
if(!s5){if(--x==0){x=batas;}lcd_clear();}
if(!s2){if(++cut[x]==6){cut[x]=1;}}
if(!s3){if(--cut[x]<=0){cut[x]=5;}}
if(!s4){lcd_clear();
for(count2=0;count2<=batas;count2++){ecut[count2]=cut[count2];}
                saved();
                break;}
delay_ms(150);
}
}

//-------------fungsi setting counter 2--------//
void pintas1()
{int x;
x=1;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
lcd_putsf("    [SETTING]");
lcd_gotoxy(0,0);
sprintf(buff,"Count2 %02d ",x);
lcd_gotoxy(0,1);
lcd_puts(buff);
if(cut1[x]==1){
lcd_gotoxy(11,1);
lcd_putsf("Lost   ");
}
if(cut1[x]==2){
lcd_gotoxy(11,1);
lcd_putsf("Kanan  ");

}
if(cut1[x]==3){
lcd_gotoxy(11,1);
lcd_putsf("Kiri   ");
}
if(cut1[x]==4){
lcd_gotoxy(11,1);
lcd_putsf("Lost1  ");
}
if(cut1[x]==5){
lcd_gotoxy(11,1);
lcd_putsf("Stop   ");
}
if(!s1){if(++x>batas){x=1;}lcd_clear();}
if(!s5){if(--x==0){x=batas;}lcd_clear();}
if(!s2){if(++cut1[x]==6){cut1[x]=1;}}
if(!s3){if(--cut1[x]<=0){cut1[x]=5;}}
if(!s4){lcd_clear();
for(count2=0;count2<=batas;count2++){ecut1[count2]=cut1[count2];}
                saved();
                break;}
delay_ms(150);
}
}

//-------------fungsi setting delay rotate--------//
void delay()
{int x;
x=1;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
lcd_putsf("    [SETTING]");
lcd_gotoxy(0,0);
sprintf(buff,"Rotate%02d =%03d    ",x,del[x]);
lcd_gotoxy(0,1);
lcd_puts(buff);
if(!s1){if(++x>batas){x=1;}lcd_clear();}
if(!s5){if(--x==0){x=batas;}lcd_clear();}
if(!s2){del[x]=del[x]+5;}
if(!s3){del[x]=del[x]-5;}
if(!s4){lcd_clear();
for(count2=0;count2<=batas;count2++){edel[count2]=del[count2];}
                saved();
                break;}
delay_ms(150);
}
}

//-------------fungsi setting kecepatan 1 counter--------//
void kecepatan()
{int xx;
xx=0;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
lcd_putsf("    [SETTING]");
lcd_gotoxy(0,0);
sprintf(buff,"Speed1 %02d =%03d    ",xx,speed[xx]);
lcd_gotoxy(0,1);
lcd_puts(buff);
if(!s1){if(++xx>batas){xx=0;}lcd_clear();}
if(!s5){if(--xx==-1){xx=batas;}lcd_clear();}
if(!s2){speed[xx]=speed[xx]+5;}
if(!s3){speed[xx]=speed[xx]-5;}
if(!s4){lcd_clear();
for(count2=0;count2<=batas;count2++){espeed[count2]=speed[count2];}
                saved();
                break;}
delay_ms(150);
}
}

//-------------fungsi setting kecepatan 2 counter--------//
void kecepatan1()
{int xx;
xx=0;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
lcd_putsf("    [SETTING]");
lcd_gotoxy(0,0);
sprintf(buff,"Speed2 %02d =%03d    ",xx,speed1[xx]);
lcd_gotoxy(0,1);
lcd_puts(buff);
if(!s1){if(++xx>batas){xx=0;}lcd_clear();}
if(!s5){if(--xx==-1){xx=batas;}lcd_clear();}
if(!s2){speed1[xx]=speed1[xx]+5;}
if(!s3){speed1[xx]=speed1[xx]-5;}
if(!s4){lcd_clear();
for(count2=0;count2<=batas;count2++){espeed1[count2]=speed1[count2];}
                saved();
                break;}
delay_ms(150);
}
}

//-------------fungsi setting rencana cek point set timer--------// 
void rencana1()
{int xx;
xx=1;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
lcd_putsf("    [SETTING]");
lcd_gotoxy(0,0);
sprintf(buff,"Cp%02d Time=%03d    ",xx,plan[xx]);
lcd_gotoxy(0,1);
lcd_puts(buff);
if(!s1){if(++xx>20){xx=1;}lcd_clear();}
if(!s5){if(--xx==0){xx=20;}lcd_clear();}
if(!s2){plan[xx]=plan[xx]+1;}
if(!s3){plan[xx]=plan[xx]-1;}
if(!s4){lcd_clear();
for(count2=0;count2<=20;count2++){eplan[count2]=plan[count2];}
                saved();
                break;}
delay_ms(150);
}
}

//-------------fungsi setting rencana cek point set counter--------//
void rencana2()
{int xx;
xx=1;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
lcd_putsf("    [SETTING]");
lcd_gotoxy(0,0);
sprintf(buff,"Cp%02d Read=%03d    ",xx,read[xx]);
lcd_gotoxy(0,1);
lcd_puts(buff);
if(!s1){if(++xx>20){xx=1;}lcd_clear();}
if(!s5){if(--xx==0){xx=20;}lcd_clear();}
if(!s2){read[xx]=read[xx]+1;}
if(!s3){read[xx]=read[xx]-1;}
if(!s4){lcd_clear();
for(count2=0;count2<=20;count2++){eread[count2]=read[count2];}
                saved();
                break;}
delay_ms(150);
}
}

//-------------fungsi ceking sensor--------//
void ceksensor()                 
{int xx=0;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
lcd_putsf("    [SETTING]");
lcd_gotoxy(0,0);
sprintf(buff,"Sensor%d ->%d     ",xx,in);
lcd_gotoxy(0,1);
lcd_puts(buff);
if(xx>13){xx=0;}
if(xx<0){xx=13;}
if(!s2){xx=xx+1;}
if(!s3){xx=xx-1;}
if(xx<7){L=1;R=0;in=read_adc(xx);}
if(xx>=7){L=0;R=1;in=read_adc(xx-7);}
if(!s4){
                lcd_clear();
                break;}
delay_ms(150);
}
}

//-------------fungsi setting mode darurat--------//
void darurat()
{
int ss=0;
while(1){
if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
lmp=1;
lcd_putsf("    [SETTING]");
lcd_gotoxy(0,0);
sprintf(buff,"Cek Point[%02d]      ",ss);
lcd_gotoxy(0,1);
lcd_puts(buff);
if(!s2){if(++ss>batas){ss=0;}delay_ms(150);}
if(!s3){if(--ss<=-1){ss=batas;}delay_ms(150);}
if(!s4||!s6){lcd_clear();
                if(ss>0){start=read[ss];
                timer[start]=plan[ss];
                }
                lcd_clear();
                break;}
}
}

//-------------fungsi setting menu--------//
void setting()
{


int n;
n=0;
while(1){
lmp=1;

if(!s1||!s2||!s3||!s4||!s5){led=0;}
else{led=1;}
if(!s5){n=n-1;lcd_clear();}
if(n==-1){n=18;}
if(!s1){n=n+1;lcd_clear();}
if(n==19){n=0;} 
                
                if(n==1){
                lcd_gotoxy(4,0);
                lcd_putsf("[SETTING]");
                        sprintf(buff,"1.Calibration %d ", m);
                        lcd_gotoxy(0,1);
                        lcd_puts(buff);
                        if(!s2){autoscan();}
                        if(!s3){m++;
                        if(m==2){m=0;}}}
                if(n==2){
                lcd_gotoxy(4,0);
                lcd_putsf("[SETTING]");      
                        sprintf(buff,"2.Speed=%d   ",max1);          
                        lcd_gotoxy(0,1);
                        lcd_puts(buff);
                        if(!s2){max1=max1+5;
                        if (max1>255){max1=0;}}
                        if(!s3){max1=max1-5;
                        if (max1<0){max1=255;}}}
                if(n==3 ){
                lcd_gotoxy(4,0);
                lcd_putsf("[SETTING]");
                        sprintf(buff,"3.Kec.Belok=%d   ",lc);
                        lcd_gotoxy(0,1);
                        lcd_puts(buff);
                        if(!s2){lc=lc+5;
                        if (lc>255){lc=0;}}
                        if(!s3){lc=lc-5;
                        if (lc<0){lc=255;}}}         
                if(n==4){
                lcd_gotoxy(4,0);
                lcd_putsf("[SETTING]");
                        sprintf(buff,"4.");
                        lcd_gotoxy(0,1);
                        lcd_puts(buff);
                               
                        }
                if(n==5){
                lcd_gotoxy(4,0);
                lcd_putsf("[SETTING]");
                        lcd_gotoxy(0,1);
                        lcd_putsf("5.PID ");
                        if(!s2){pid();}}       
                if(n==6){
                awalStrategi:
                lcd_clear();
                lcd_gotoxy(4,0);
                lcd_putsf("[SETTING]");
                  lcd_gotoxy(0,1);
                  lcd_putsf("6.Strategi");
                  if(!s2){
                   int p_strategi=0;
                  lcd_clear();
                   
                while(1){ 
                if(!s1){p_strategi=p_strategi+1;lcd_clear();delay_ms(250);}
                if(!s5){p_strategi=p_strategi-1;lcd_clear();delay_ms(250);}
                if(p_strategi==-1){p_strategi=4;}
                if(p_strategi==5){p_strategi=0;}
                         
                        if(p_strategi==0){
                        lcd_gotoxy(2,0);
                        lcd_putsf("[6.Strategi]");
                        sprintf(buff,"1.Speed Stra=%d   ", vc);
                        lcd_gotoxy(0,1);
                        lcd_puts(buff);
                        if(!s2){
                        vc=vc+5;delay_ms(150);
                        if(vc>255){vc=0;}}
                        if(!s3){vc=vc-5;delay_ms(150);
                        if (vc<0){vc=255;}} 
                        }
                
                        if(p_strategi==1){
                        lcd_gotoxy(2,0);
                        lcd_putsf("[6.Strategi]");
                        lcd_gotoxy(0,1);
                        lcd_putsf("2.Start A");
                        }
                        
                        if(p_strategi==2){
                        lcd_gotoxy(2,0);
                        lcd_putsf("[6.Strategi]");
                        lcd_gotoxy(0,1);
                        lcd_putsf("3.Start B");
                        }
                        
                        if(p_strategi==3){
                        lcd_gotoxy(2,0);
                        lcd_putsf("[6.Strategi]");
                        lcd_gotoxy(0,1);
                        lcd_putsf("4.Start C");
                        }
                        
                        if(p_strategi==4){
                        lcd_gotoxy(2,0);
                        lcd_putsf("[6.Strategi]");
                        lcd_gotoxy(0,1);
                        lcd_putsf("5.Start D");
                        }
                        
                        if(!s6){goto awalStrategi;}
                  
                  }
                  
                  
                }
                /*
                int p_strategi=0;
                while(1){ 
                if(!s3){p_strategi=p_strategi+1;lcd_clear();delay_ms(250);}
                if(p_strategi==2){p_strategi=0;} 
                        if(p_strategi==0){
                        lcd_gotoxy(0,1);
                        lcd_putsf("6.Strategi [1]");
                        }
                        
                        if(p_strategi==1){
                        lcd_gotoxy(0,1);
                        lcd_putsf("6.Strategi [2]");
                        }
                
                } */
                        
                       //if(!s2){pintas();}
                        
                        }
                if(n==7){
                        lcd_gotoxy(0,1);
                        lcd_putsf("7.");
                        //if(!s2){pintas1();}
                        }                              
                
                if(n==8){
                        lcd_gotoxy(0,1);
                        lcd_putsf("8.Timer      ");
                        if(!s2){waktu();}}
                if(n==9){
                        lcd_gotoxy(0,1);
                        lcd_putsf("9.Speed1 Count     ");
                        if(!s2){kecepatan();}}
                if(n==10){
                        lcd_gotoxy(0,1);
                        lcd_putsf("10.Speed2 Count     ");
                        if(!s2){kecepatan1();}}
                if(n==11){
                        lcd_gotoxy(0,1);
                        lcd_putsf("11.Delay       ");
                        if(!s2){delay();}}                                                     
                if(n==12){
                        lcd_gotoxy(0,1);
                        lcd_putsf("11.Plan Timer    ");
                        if(!s2){rencana1();}}  
                if(n==13){
                        lcd_gotoxy(0,1);
                        lcd_putsf("12.Atur CP");
                        if(!s2){rencana2();}}                     
                if(n==14){
                        lcd_gotoxy(0,1);
                        if(mode==1){lcd_putsf("13.[Counter] Normal ");} 
                        if(mode==0){lcd_putsf("13.Jalan Aja");}
                        if(!s2){mode=0;}
                        if(!s3){mode=1;}
                        }
                if(n==15){
                        lcd_gotoxy(0,1);
                        if(modekanan==1){lcd_putsf("14.Counter 2 ");} 
                        if(modekanan==0){lcd_putsf("14.Counter 1 ");}
                        if(!s2){modekanan=1;}
                        if(!s3){modekanan=0;}}
                if(n==16){
                        sprintf(buff,"15.Smoothing=%d   ", pulsa);
                        lcd_gotoxy(0,1);
                        lcd_puts(buff);
                        if(!s2){
                        pulsa=pulsa+1;if (pulsa>255){pulsa=0;}}
                        if(!s3){pulsa=pulsa-1;if (pulsa<0){pulsa=255;}}} 
                if(n==17){
                        lcd_gotoxy(0,1);
                        lcd_putsf("16.Cek Sensor");
                        if(!s2){ceksensor();}} 
                if(n==18){
                        sprintf(buff,"17.Rem =%d   ",lc1);
                        lcd_gotoxy(0,1);
                        lcd_puts(buff);
                        if(!s2){lc1=lc1+5;
                        if (lc1>255){lc1=0;}}
                        if(!s3){lc1=lc1-5;
                        if (lc1<0){lc1=255;}}}                  
                if(n==0){

                        lcd_gotoxy(0,1);
                        if(encomp==2){lcd_putsf("18.White Line ");}
                        if(encomp==1){lcd_putsf("18.Black Line ");} 
                        if(encomp==0){lcd_putsf("18.Auto Line  ");}
                        if(!s2){encomp=encomp+1;if (encomp>2){encomp=0;}}
                        if(!s3){encomp=encomp-1;if (encomp<0){encomp=2;}}}        
                            
        if(!s4){
                if(pulsa!=epulsa){epulsa=pulsa;}
                if(mode!=emode){emode=mode;}
                if(modekanan!=emodekanan){emodekanan=modekanan;}
                if(lc!=elc){elc=lc;}
                if(lc1!=elc1){elc1=lc1;}
                if(vc!=evc){evc=vc;}
                if(max1!=emax1){emax1=max1;}
                if(encomp!=eencomp){eencomp=encomp;}
                saved();
                break;}
delay_ms(150);
}
}

//-------------fungsi scansensor--------//
void scansensor()
{
if(sensitive[adc]<in){sen=0;sm=0;}
dep=0;
sam=0;
sam1=0;
        for(adc=0;adc<=6;adc++){
        in=read_adc(adc+1);
        L=1;
        R=0;
if(adc==0){
        lcd_gotoxy(8,0);
        if(in>sensitive[adc]){
        dep=dep+64;
        lcd_putchar(0xff);sen=8;
        }
        else lcd_putchar(0x5f);
        }
if(adc==1){
        lcd_gotoxy(6,0);
        if(in>sensitive[adc]){
        dep=dep+128;
        lcd_putchar(0xff);sen=6;
        }
        else lcd_putchar(0x5f);
        }
if(adc==2){
        lcd_gotoxy(5,0);
        if(in>sensitive[adc]){
        dep=dep+256;
        lcd_putchar(0xff);sen=5;
        }
        else lcd_putchar(0x5f);
        }
if(adc==3){
        lcd_gotoxy(4,0);
        if(in>sensitive[adc]){
        dep=dep+512;  
        lcd_putchar(0xff);sen=4;
        }
        else lcd_putchar(0x5f);
        }
if(adc==4){
        lcd_gotoxy(3,0);
        if(in>sensitive[adc]){
        dep=dep+1024;
        lcd_putchar(0xff);sen=3;
        }
        else lcd_putchar(0x5f);
        }
if(adc==5){
        lcd_gotoxy(2,0);
        if(in>sensitive[adc]){
        dep=dep+2024;
        lcd_putchar(0xff);sen=2;
        }
        else lcd_putchar(0x5f);
        }
if(adc==6){
        lcd_gotoxy(1,0);
        if(in>sensitive[adc]){
        sam=sam+2;
        lcd_putchar(0xff);sen=1;
        }
        else lcd_putchar(0x5f);
        }
}
for(adc=7;adc<=13;adc++){
        in=read_adc(adc-6);
        L=0;
        R=1; 
if(adc==7){
        lcd_gotoxy(7,0);
        if(in>sensitive[adc]){
        dep=dep+32;
        lcd_putchar(0xff);sen=7;
        }
        else lcd_putchar(0x5f);
        }
if(adc==8){
        lcd_gotoxy(9,0);
        if(in>sensitive[adc]){
        dep=dep+16; 
        lcd_putchar(0xff);sen=9;
        }
        else lcd_putchar(0x5f);
        }
if(adc==9){
        lcd_gotoxy(10,0);
        if(in>sensitive[adc]){
        dep=dep+8;
        lcd_putchar(0xff);sen=10;
        }
        else lcd_putchar(0x5f);
        }
if(adc==10){
        lcd_gotoxy(11,0);
        if(in>sensitive[adc]){
        dep=dep+4;
        lcd_putchar(0xff);sen=11;
        }
        else lcd_putchar(0x5f);
        }
if(adc==11){
        lcd_gotoxy(12,0);
        if(in>sensitive[adc]){
        dep=dep+2;  
        lcd_putchar(0xff);sen=12;
        }
        else lcd_putchar(0x5f);
        }
if(adc==12){
        lcd_gotoxy(13,0);
        if(in>sensitive[adc]){                          
        dep=dep+1;
        lcd_putchar(0xff);sen=13;
        }
        else lcd_putchar(0x5f);
        }
if(adc==13){
        lcd_gotoxy(14,0);
        if(in>sensitive[adc]){
        sam=sam+1;
        lcd_putchar(0xff);sen=14;
        }
        else lcd_putchar(0x5f);
        }
}
depan=dep;
samping=sam;
samping1=sam1;
}

void stop_time(){
pwm_off();

lcd_clear();
while(1){
lmp=1;
aktif=0;
output=1;
time[start]=cacah;
 lcd_gotoxy(0,1);
 sprintf(buff,"TIMER:%d COUNT:%d",time[start],start);
 lcd_puts(buff);
 delay_ms(1);
motor(0,0);
if(time[start]>=timer[start])break;
}
pwm_on();
output=0;
lcd_clear();
}

void no_line(){
lcd_clear();
lmp=1;
 lcd_gotoxy(0,1);
 sprintf(buff,"%03d<%02d>%03d %03d   ",max1,start,max1,tunda);
 lcd_puts(buff);
tunda=del[start]; 
motor(max1,max1);
delay_ms(tunda);
aktif=0;
lcd_clear();
}
//-------------fungsi rem--------//
void ngerem()
{
if(lc1>0){
mundur();
delay_ms(lc1);
}
}

//-------------fungsi program yang di jalankan--------//
void program(){
if(input==0)output=1;
else output=0;
lmp=0;
time[start]=cacah;
if(time[start]<timer[start]&&mode==1){led=0;max1=speed[start];}
if(time[start]>=timer[start]&&mode==1){led=1;max1=speed1[start];}
if(error>=-11&&error<=11){
protec=0;
}
/*
if(error<=-31||error>=31){
lock=0;
}

*/
if(error<=52 && error>=20){lock=0;}
if(error<=-52 && error<=-20){lock=0;}


scansensor();
if(encomp==1){lmp=0;}
if(encomp==2){depan= 4095-dep;
            samping=13-sam;
            lmp=1;
            }
if(invers==1&&encomp==0){
            depan= 4095-dep;
            samping=13-sam;
            lmp=1;
            }
         else {
            invers=0;
            inv = 0;
            lmp=0;
             }
 switch (depan)  {
 case 0b111111111110:
 case 0b111111111100:
 case 0b111111111101:
 case 0b111111111001:
 case 0b111111111011:
 case 0b111111110011:
 case 0b111111110111:
 case 0b111111100111:
 case 0b111111101111:
 case 0b111111001111:
 case 0b111111011111:

 case 0b111110011111:
 
 case 0b111110111111:
 case 0b111100111111:
 case 0b111101111111:
 case 0b111001111111:
 case 0b111011111111:
 case 0b110011111111:
 case 0b110111111111:
 case 0b100111111111:
 case 0b101111111111:
 case 0b001111111111:
 case 0b011111111111:
 if (inv==0&&encomp==0)invers++;
 else inv = 0; break;                                
 case 0b000000000001:        error=-31;   break;
 case 0b000000000011:       error=-27;   break; 
 case 0b000000000010:       error=-25;   break;
 case 0b000000000110:       error=-21;   break;
 case 0b000000000100:       error=-17;   break;
 case 0b000000001100:       error=-15;   break;
 case 0b000000001000:       error=-11;   break;
 case 0b000000011000:       error=-7;   break;
 case 0b000000010000:       error=-5;   break;
 case 0b000001010000:       error=-3;   break; //di balik
 case 0b000001000000:       error=-1;   break; //di balik
 case 0b000001100000:       error=0;    break;
 
 case 0b000000100000:       error=1;    break; //di balik
 case 0b000010100000:       error=3;    break; //di balik
 case 0b000010000000:       error=5;    break;
 case 0b000110000000:       error=7;    break;
 case 0b000100000000:       error=11;   break; 
 case 0b001100000000:       error=15;   break;
 case 0b001000000000:       error=17;   break;
 case 0b011000000000:       error=21;   break;
 case 0b010000000000:       error=25;   break;
 case 0b110000000000:       error=27;   break;
 case 0b100000000000:       error=31;   break;
 
 case 0b000000000111:       error=-21;    break;
 case 0b000000001111:       error=-17;    break;
 case 0b000000001110:       error=-15;    break;
 case 0b000000011110:       error=-11;    break;
 case 0b000000011100:       error=-7;     break;
 case 0b000001011100:       error=-5;     break; //di balik
 case 0b000001011000:       error=-3;     break; //di balik
 case 0b000001110000:
 case 0b111001101111:
 case 0b111011100111:
 case 0b111111111111:
 case 0b011111111110:
 case 0b001111111100:       
 case 0b000111111000:
 case 0b000011100000:
 case 0b000011110000:       error=0;     break;
  
 case 0b000110100000:       error=3;     break; //di balik
 case 0b001110100000:       error=5;     break; //di balik
 case 0b001110000000:       error=7;     break;
 case 0b011110000000:       error=11;    break;
 case 0b011100000000:       error=15;    break;
 case 0b111100000000:       error=17;    break;
 case 0b111000000000:       error=21;    break;
 
 case 0b000000000000:           
 
// Right sharp
 if(scan==0){
 if(samping==0b01){
 if(depan==0){ 
 if(lock==0)ngerem();
 lock=1;
 error=52;
 kananlancip();
 scan=1;                                                            
 }
 }
 
 if(depan==0b000000000001){  
 if(lock==0)ngerem();
 lock=1;
 error=52;
 kananlancip();
 scan=1;
 }
 
  
 if(depan==0b000000000010){  
 if(lock==0)ngerem();
 lock=1;
 error=52;
 kananlancip();
 scan=1;
 }
 
 /*
 if(samping==0b1100){
 if(depan==0){ 
 if(lock==0)ngerem();
 lock=1;
 error=52;
 kananlancip();
 scan=1;
 }
 }
 */
 // lancip kiri
 if(samping==0b10){
  if(depan==0){
  if(lock==0)ngerem();
  lock=1;
  error=-52;
  kirilancip();
  scan=1;
  }
  }
   
  
  if(depan==0b010000000000){
  if(lock==0)ngerem();
  lock=1;
  error=-52;
  kirilancip();
  scan=1;
  }
  
  if(depan==0b100000000000){
  if(lock==0)ngerem();
  lock=1;
  error=-52;
  kirilancip();
  scan=1;
  }
 
  
  
  } 
  
  
  
  
  } 
  if(samping1<=0){xcc=0;}
  if(samping1>0||cut[start+1]==5){
        if(protec==0&&mode==1){
        if(time[start]>=timer[start]){
        aktif=1;cacah=0; 
        if(pass>0)start++;
        counting=cut[start];
        if(counting==1||counting==2||counting==3||counting==4||counting==5){
        if(lc1>0){
        if(xcc<2)xcc++;
        if(xcc==1){
        lmp=0;
        ngerem();
        aktif=0;
        }
        }
        }
        if(counting==2){kanan();}
        if(counting==3){kiri();}
        if(counting==4){no_line();}
        if(counting==5){stop_time();}
        }
        protec=1;
        }
        }
        
// rumus PID                       
rumus_pid();
if(max1==0)motor(0,0);
else motor(lpwm,rpwm);
if(error>=-11&&error<=11){
 scan=0;aktif=0;
}
else if ((error>50)||(error<-50)){
 scan=1;
        if(error==52)kananlancip();
        else if(error==-52)kirilancip();        
 }
 lcd_gotoxy(0,1);
 //sprintf(buff,"%03d<%02d>%03d %03d   ",lpwm,start,rpwm,cacah);
 sprintf(buff,"%03d <%02d> %03d %03d   ",lpwm,error,rpwm,cacah);
 lcd_puts(buff);
 } 
// Declare your global variables here







void pilihStart(){
while(1){
if(!s6){pilih_start=pilih_start+1;delay_ms(200);}
            if(pilih_start=4){pilih_start=0;}
                if(pilih_start==0){
                    lcd_gotoxy(0,1);
                    lcd_putsf(".Start=A");
                    lcd_gotoxy(9,1);
                    lcd_putsf(" CP=1");
                }
                
                if(pilih_start==1){
                    lcd_gotoxy(0,1);
                    lcd_putsf(".Start=B");
                    lcd_gotoxy(9,1);
                    lcd_putsf(" CP=1");
                }
                
                if(pilih_start==2){
                    lcd_gotoxy(0,1);
                    lcd_putsf(".Start=C");
                    lcd_gotoxy(9,1);
                    lcd_putsf(" CP=1");
                } 
                
                if(pilih_start==3){
                    lcd_gotoxy(0,1);
                    lcd_putsf(".Start=D");
                    lcd_gotoxy(9,1);
                    lcd_putsf(" CP=1");
                }
}

}






void main(void)
{
int p_start=0;

PORTA=0xFF;
DDRA=0x00;
PORTB=0x00;
DDRB=0x08;
PORTC=0x3F;
DDRC=0xC0;
PORTD=0x81;
DDRD=0xFE;
TCCR0=0x05;
TIMSK=0x01;
ADCSRA=0x84;
lcd_init(16);
lcd_gotoxy(2,0);
lcd_puts("  Welcome To");
delay_ms(200);
lcd_gotoxy(3,1);
lcd_puts(" TEUM CORP.");
pwm_off();
stop();
delay_ms(1000);

if(!s3){
int n=0;
lmp=1;
lcd_clear();
delay_ms(500);

while(1){

if(!s3){n=n+1;lcd_clear();delay_ms(200);}
if(n==2){n=0;}

    if(n==0){
    lcd_gotoxy(0,0);
    lcd_putsf("Format Data[N]");
        if(!s2){
         lcd_gotoxy(0,0);
         lcd_putsf("batal format");
         delay_ms(500); 
         goto exit;}
    }
    
    if(n==1){
    lcd_gotoxy(0,0);
    lcd_putsf("Format Data[Y]");    
        if(!s2){
        lcd_gotoxy(0,0);
        lcd_putsf("Proses Format"); 
        
lcd_gotoxy(0,1);
lcd_putsf("................");
//-------------start formating--------//
for(count2=1;count2<=batas;count2++){ecut[count2]=1;}
for(count2=1;count2<=batas;count2++){ecut1[count2]=1;}
for(count2=1;count2<=batas;count2++){edel[count2]=255;}
for(count2=0;count2<=20;count2++){eread[count2]=0;}
for(count2=0;count2<=20;count2++){eplan[count2]=0;}
for(count2=0;count2<=batas;count2++){espeed[count2]=100;}
for(count2=0;count2<=batas;count2++){espeed1[count2]=80;}
for(count2=0;count2<=batas;count2++){etimer[count2]=1;}
for(adc=0;adc<16;adc++){esensitive[adc]=100;}
lmp=1;
eencomp=0;
emode=0;
emodekanan=0;
epulsa=5;
ekp=10;
ekd=100;
eki=0;
elc=120;
elc1=0;
evc=120;
emax1=100;
loading();
lcd_gotoxy(0,0);
lcd_putsf("Format Selesai!");
delay_ms(1000);

goto exit;
        
        
        }
    
    }

  }

}

exit2:
stop();
lmp=1;
//-------------data dari eeprom di copy ke ram--------//
for(count2=1;count2<=batas;count2++){cut[count2]=ecut[count2];}
for(count2=1;count2<=batas;count2++){cut1[count2]=ecut1[count2];}
for(count2=1;count2<=batas;count2++){del[count2]=edel[count2];}
for(count2=0;count2<=20;count2++){read[count2]=eread[count2];}
for(count2=0;count2<=20;count2++){plan[count2]=eplan[count2];}
for(count2=0;count2<=batas;count2++){speed[count2]=espeed[count2];}
for(count2=0;count2<=batas;count2++){speed1[count2]=espeed1[count2];}
for(count2=0;count2<=batas;count2++){timer[count2]=etimer[count2];}
for(count2=0;count2<=batas;count2++){time[count2]=0;}
for(adc=0;adc<16;adc++){sensitive[adc]=esensitive[adc];}
mode=emode;
modekanan=emodekanan; 
encomp=eencomp;
pulsa=epulsa;
start=0;
aktif=1;
cacah=0;
lc=elc;
lc1=elc1; 
vc=evc;        
max1=emax1;
kp=ekp;
ki=eki;
kd=ekd;
SP=0;
PV = 0;
lasterror = 0;
error = 0;
led=1;
if (!s1){goto exit3;}
goto exit;
exit3:
lcd_clear();
L=0;
R=0;
aktif=1;
setting();
led=1;

exit4:
pilihStart();

exit:
lcd_clear();

while (1) {
lmp=1;
scansensor();

if(!s3){p_start=p_start+1;delay_ms(200);}
if(p_start==2){p_start=0;}

        if(p_start==0){
            lcd_gotoxy(0,1);
            lcd_putsf(".Start=A");
            lcd_gotoxy(9,1);
            lcd_putsf(" CP=1");
            goto exit4;
               
        }
        
        if(p_start==1){
            lcd_gotoxy(0,1);
            lcd_putsf(" Start=A");
            lcd_gotoxy(9,1);
            lcd_putsf(".CP=1");
        
        }





//sprintf(buff,"[%d-%d] SCAN    ",sen,sam);
//lcd_puts(buff);
//if(pass>=0){lcd_putsf("+");}
//if(pass<=0){lcd_putsf("-");}
if (!s1)goto exit2; //masuk ke menu setting
//if (!s4||!s6)break;
}
lcd_clear();
if (mode==1){delay_ms(500);}
L=0;
R=0;

//-------------data dari eeprom di copy ke ram--------//
for(count2=1;count2<=batas;count2++){cut[count2]=ecut[count2];}
for(count2=1;count2<=batas;count2++){cut1[count2]=ecut1[count2];}
for(count2=1;count2<=batas;count2++){del[count2]=edel[count2];}
for(count2=0;count2<=20;count2++){read[count2]=eread[count2];}
for(count2=0;count2<=20;count2++){plan[count2]=eplan[count2];}
for(count2=0;count2<=batas;count2++){speed[count2]=espeed[count2];}
for(count2=0;count2<=batas;count2++){speed1[count2]=espeed1[count2];}
for(count2=0;count2<=batas;count2++){timer[count2]=etimer[count2];}
for(count2=0;count2<=batas;count2++){time[count2]=0;}
for(adc=0;adc<16;adc++){sensitive[adc]=esensitive[adc];}
if(modekanan==1){for(count2=0;count2<batas;count2++){cut[count2]=cut1[count2];}}
if (mode==1)darurat();
lmp=0;
pwm_on();
aktif=1;
#asm("sei")
while (1)
      {
      // Place your code here
      program(); 
      scansensor();
      if (!s1){pwm_off();stop();goto exit;}     
      };
      
}
