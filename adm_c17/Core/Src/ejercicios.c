/*
 * ejercicios.c
 *
 *  Created on: 24 may. 2022
 *      Author: gaston
 */
#include "ejercicios.h"
#define UINT12_MAX 4095

void productoEscalar32(uint32_t * vectorIn, uint32_t * vectorOut,uint32_t longitud, uint32_t escalar){
	int64_t index ;
	uint32_t result_op ;
	// cuidado al contar para atras con  variable uint!
	for (index = (longitud-1) ; index>=0 ; index--){
		result_op = vectorIn[index] * escalar ;
		vectorOut[index] = (result_op< vectorIn[index] || result_op< escalar)?UINT32_MAX:(uint32_t)result_op ;
	}

}



void productoEscalar16(uint16_t * vectorIn, uint16_t * vectorOut,uint32_t longitud, uint16_t escalar){
	int64_t index =  0 ;
	uint16_t length =(uint16_t) longitud-1  ;
	uint16_t result_op ;
	for (index = 0 ; index<length  ; index++){
		result_op =vectorIn[index]*escalar ;
		vectorOut[index] = (result_op < vectorIn[index]||result_op< escalar )?UINT16_MAX:(uint16_t)result_op ;
	}
}

void productoEscalar12(uint16_t * vectorIn, uint16_t * vectorOut,uint32_t longitud, uint16_t escalar){
	int64_t index ;
	uint32_t result_op ;
	for (index = longitud-1 ; index>=0 ; index--){
		result_op =vectorIn[index]*escalar ;
		vectorOut[index] = (result_op >(uint16_t)UINT12_MAX || result_op<vectorIn[index] || result_op < escalar)?UINT12_MAX:(uint16_t)result_op ;
	}
}


void zeros (uint32_t *vector,uint32_t longitud){
	int64_t index = longitud - 1 ; // verificar si "longitud al restar uno no se "rosquea"

	for (index = longitud - 1; index>=0; index--){
		vector[index] = 0 ;
	}


}


void pack32to16 (int32_t * vectorIn, int16_t *vectorOut, uint32_t longitud){
	// me quedo con los 16 bits mas significativos
	int16_t index = 0   ;
    int32_t shifter = 16;
    int32_t aux_value ;
    int16_t output_value[longitud] ;

    for(index = 0 ; index<longitud; index++){
    //	vectorOut[index] = (vectorIn[index]>>16);
     	aux_value =(vectorIn[index]  >> 16) ;
     	output_value[index] =(int16_t) aux_value; //aux_value = aux_value >> 16 ;
     	vectorOut[index] =  output_value[index] ;
    }
  //  memcpy(vectorOut[0],output_value[0],2 ) ; //destino, fuente, num_bytes

}



int32_t max (int32_t * vectorIn, uint32_t longitud){
	uint32_t index_max = 0 ;
	int32_t max = vectorIn[index_max] ;
	uint32_t index = 0 ;
	for (index = 1 ; index<longitud; index++){
		if (vectorIn[index]>max){
			max = vectorIn[index] ;
			index_max = index ;
		}
	}
	return index_max ;
}


