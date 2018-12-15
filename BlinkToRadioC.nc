// $Id: BlinkToRadioC.nc,v 1.5 207/09/13 23:10:23 scipio Exp $

/*
 * "Copyright (c) 2000-2006 The Regents of the University  of California.  
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement is
 * hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 * 
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
 * CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 * 
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 *
 */

/**
 * Implementation of the BlinkToRadio application.  A counter is
 * incremented and a radio message is sent whenever a timer fires.
 * Whenever a radio message is received, the three least significant
 * bits of the counter in the message payload are displayed on the
 * LEDs.  Program two motes with this application.  As long as they
 * are both within range of each other, the LEDs on both will keep
 * changing.  If the LEDs on one (or both) of the nodes stops changing
 * and hold steady, then that node is no longer receiving any messages
 * from the other node.
 *
 * @author Prabal Dutta
 * @date   Feb 1, 2006
 */
#include <Timer.h>
#include "BlinkToRadio.h"

module BlinkToRadioC {
  uses interface Boot;
  uses interface Leds;
  uses interface Timer<TMilli> as Timer0;
  uses interface Packet;
  uses interface AMPacket;
  uses interface AMSend;
  uses interface Receive;
  uses interface SplitControl as AMControl;
}
implementation {

  uint16_t counter;
  message_t pkt;
  bool busy = FALSE;

  void setLeds(uint16_t val) {
    if (val & 0x01)
      call Leds.led0On();
    else 
      call Leds.led0Off();
    if (val & 0x02)
      call Leds.led1On();
    else
      call Leds.led1Off();
    if (val & 0x04)
      call Leds.led2On();
    else
      call Leds.led2Off();
  }

  event void Boot.booted() {
    call AMControl.start();
    dbg("Boot", "Aplication booted.\n");
  }

  event void AMControl.startDone(error_t err) {
    if (err == SUCCESS) {
      call Timer0.startPeriodic(TIMER_PERIOD_MILLI);
    }
    else {
      call AMControl.start();
    }
  }
  
  int pegaIdVerticeDoProximo(int idMenor, int idOrigem) {
    switch(idMenor) {
      case 0:
        return idOrigem - 1;
      case 1:
        return idOrigem + 1;    
      case 2:
        return idOrigem - 15;    
      case 3:
        return idOrigem + 15;
      case 4:
        return idOrigem - 16;
      case 5:
        return idOrigem + 14;
      case 6:
        return idOrigem - 14;
      case 7:
        return idOrigem + 16;
      default:
        dbg("Boot", "DEU RUIM DEMAIS");
    }
  }

  int calculaDistancia(int* noh1, int* noh2) {
    int x = noh1[0] - noh2[0];
    int y = noh1[1] - noh2[1];
    x = x*x;
    y = y*y;
    return (x + y);
  }
      
  int calculaMenorDistancia(int* esquerda, int* direita, int* acima, int* abaixo, 
                            int* esquerdaAcima, int* esquerdaAbaixo, int* direitaAcima, 
                            int* direitaAbaixo, int* destinoFinal) {
    int* vetor[] = {
                      esquerda, direita, acima, abaixo, esquerdaAcima, 
                      esquerdaAbaixo, direitaAcima, direitaAbaixo	
                    };
    
    int menorDistancia = -1;

    int idMenor = 0;
    int posicao = 0;
    int distancia;
    
    while(menorDistancia == -1) {
      if(vetor[posicao] == NULL) {
        posicao++;
      } else {
        idMenor = posicao;
        menorDistancia = calculaDistancia(vetor[idMenor], destinoFinal);
      }
    }
    
    for(; posicao < 8; posicao++) {
      if(vetor[posicao] != NULL) {
        distancia = calculaDistancia(vetor[posicao], destinoFinal);
        if(distancia < menorDistancia) {
          menorDistancia = distancia;
          idMenor = posicao;
        }
      }
    }
    return idMenor;
    
    
  }
  
  
  int encontraIdMaisProximo(int s, int d) {
    int idProximoDestino = -1;
    int posicaoMenor = -1;
    
    bool podeCalcularEsquerda = 1;
    bool podeCalcularDireita = 1;
    bool podeCalcularAcima = 1;
    bool podeCalcularAbaixo = 1;
    
    int* esquerda = NULL;
    int* direita = NULL;
    int* acima = NULL;
    int* abaixo = NULL;
    int* esquerdaAcima = NULL;
    int* esquerdaAbaixo = NULL;
    int* direitaAcima = NULL;
    int* direitaAbaixo = NULL;
    
    int* destinoFinal = MATRIZ[d];
    
    if(MATRIZ[s][0] == 0) {
      podeCalcularEsquerda = 0;  
    }
    if(MATRIZ[s][0] == 280) {
      podeCalcularDireita = 0;
    }
    if(MATRIZ[s][1] == 0) {
      podeCalcularAcima = 0;
    }
    if(MATRIZ[s][1] == 280) {
      podeCalcularAbaixo = 0;
    }
    
    if(podeCalcularEsquerda) {
      esquerda = MATRIZ[s-1];
    }
    if(podeCalcularDireita) {
      direita = MATRIZ[s+1];
    }
    if(podeCalcularAcima) {
      acima = MATRIZ[s-15];
    }
    if(podeCalcularAbaixo) {
      abaixo = MATRIZ[s+15];
    }
    
      
    if(podeCalcularEsquerda && podeCalcularAcima) {
      esquerdaAcima = MATRIZ[s-16];
    }
    if(podeCalcularDireita && podeCalcularAcima) {
      direitaAcima = MATRIZ[s-14];
    }
    if(podeCalcularEsquerda && podeCalcularAbaixo) {
      esquerdaAbaixo = MATRIZ[s+14];
    }
    if(podeCalcularDireita && podeCalcularAbaixo) {
      direitaAbaixo = MATRIZ[s+16];
    }
    
    posicaoMenor = calculaMenorDistancia(esquerda, direita, acima, abaixo, esquerdaAcima, 
                                             esquerdaAbaixo, direitaAcima, direitaAbaixo,
                                             destinoFinal);
    idProximoDestino = pegaIdVerticeDoProximo(posicaoMenor, s);

    return idProximoDestino;
  }
  
  event void AMControl.stopDone(error_t err) {
  }

  event void Timer0.fired() {
    int idProximo;
    counter++;
    if(TOS_NODE_ID == ORIGEM) {
      idProximo = encontraIdMaisProximo(ORIGEM, DESTINO);
      dbg("Boot", "--------------- Novo Evento de envio ----------------------\n");
    
      if (!busy) {
        BlinkToRadioMsg* btrpkt = 
	  (BlinkToRadioMsg*)(call Packet.getPayload(&pkt, sizeof(BlinkToRadioMsg)));
        if (btrpkt == NULL) {
          return;
        }
        btrpkt->nodeid = TOS_NODE_ID;
        btrpkt->counter = counter;
        if (call AMSend.send(idProximo, 
          &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
          busy = TRUE;
        }
      }
    }
  }

  event void AMSend.sendDone(message_t* msg, error_t err) {
    if (&pkt == msg) {
      dbg("Boot", "Enviou!\n");
      busy = FALSE;
    }
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    if (len == sizeof(BlinkToRadioMsg)) {
      BlinkToRadioMsg* btrpkt = (BlinkToRadioMsg*)payload;
      int idProximo = encontraIdMaisProximo(TOS_NODE_ID, DESTINO);
      dbg("Boot", "Recebeu!\n");
      setLeds(btrpkt->counter);
      if(TOS_NODE_ID != DESTINO) {
        if (call AMSend.send(idProximo, 
            &pkt, sizeof(BlinkToRadioMsg)) == SUCCESS) {
            busy = TRUE;
        }
      }
      
    }
    return msg;
  }
}
