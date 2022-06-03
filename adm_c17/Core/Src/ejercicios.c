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
	int64_t index ;
	uint32_t result_op ;
	for (index = longitud-1 ; index>=0 ; index--){
		result_op =vectorIn[index]*escalar ;
		vectorOut[index] = (result_op < vectorIn[index]||result_op<escalar )?UINT16_MAX:(uint16_t)result_op ;
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


