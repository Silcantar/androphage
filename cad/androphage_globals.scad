/*******************************************************************************\
|					Global variables for Androphage keyboard.					|
|							Copyright 2026 Joshua Lucas 						|
\*******************************************************************************/

// Rendering parameters.
$fa = 1;
$fs = 0.1;

// Very small amount.
eps = 0.01;

// "Enum" of fingers/columns.
inner	= 0;
index	= 1;
middle	= 2;
ring	= 3;
pinky	= 4;
outer	= 5;

// Get the index of the last member of a vector.
function last ( vector ) = len ( vector ) - 1;

// Create a dictionary from a list of key-value pairs.
//
// If there are duplicate keys in the list, only the value for the first key
// will be returned.
function dictionary ( keyvals, key ) = [
	for ( i = keyvals ) if (i[0] == key) i[1]
][0];