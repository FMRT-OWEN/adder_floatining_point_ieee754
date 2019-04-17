/*
created by : 
AbdAlla Mohammad AboElMagd
Hussien Mostafa Said ElKholy

*/
module adder_floating_point(
input logic signed [31:0]  operand_normalized_ieee_a , operand_normalized_ieee_b ,//opreands must be enterd normalized
output logic signed [31:0]  final_sum ,//result
//output logic carry_of_fraction,//when summing fraction_a and fraction_b the result is stored in sum and carry_of_fraction {carry_of_fraction,sum}=fraction_a+fraction_b
output logic finish = 0 ,//flag of finish
//flags
//output logic zero ,
 overflow =0,

 underflow =0,
 input logic op
 );
 	integer i =0;
logic signed [24:0]  fraction_a=0 , fraction_b=0 ;//take 23 fraction in addition to implicit to not remove important bits when shifting 
logic signed [24:0] sum=0 ;//result of fraction_a (+or-) fraction_b
logic [7:0] exponent_a=0 , exponent_b=0 , positive_difference=0 , biggest_exponent=0;
//logic flip_EN;
logic clk;//clock input for stage of carry_of_fraction=0
//logic implicit_state;
logic signB;
always @(operand_normalized_ieee_a,operand_normalized_ieee_b,op)
	begin
	signB=op^operand_normalized_ieee_b[31];
	  
	// first we fill the fraction and exponent of the two floating point
		fraction_a [22:0] = operand_normalized_ieee_a [22:0] ;
		fraction_a[23] = 1 ;
		fraction_a[24] = 0 ;
		exponent_a = operand_normalized_ieee_a [30:23] ;
		
		fraction_b [22:0] = operand_normalized_ieee_b [22:0] ;
		fraction_b[23] = 1 ;
		fraction_b[24] = 0 ;
		exponent_b = operand_normalized_ieee_b [30:23] ;
	//second we compare the exponent of the two variables and get the positive difference between them
	//then we shift right the operand which has the small exponent with the positive_difference  
	if(exponent_a >= exponent_b)
		begin	
			positive_difference = exponent_a - exponent_b;
			fraction_b >>>= positive_difference ;
			biggest_exponent = exponent_a ; 
			
	//	{carry_of_fraction,sum} <= fraction_a + fraction_b;// checck blue
		end
	else 
		begin
			positive_difference = exponent_b - exponent_a;
			fraction_a>>>= positive_difference ;
			biggest_exponent = exponent_b;
			
		
		end
	// switch case to cover the special cases
		//if only operand_normalized_ieee_a is inf
		if (&exponent_a & ~&exponent_b)
			final_sum = operand_normalized_ieee_a ;
			
		//if only operand_normalized_ieee_b is inf	
		else if (&exponent_b & ~&exponent_a)
			final_sum = operand_normalized_ieee_b ;
		//if operand_normalized_ieee_a and operand_normalized_ieee_b are inf	
		else if (&exponent_a & &exponent_b )
			begin
					if (operand_normalized_ieee_a[31] != signB)
							final_sum = 32'b01111111100000000000000000000001 ;
						else begin
							final_sum[22:0] = fraction_a + fraction_b ;
							final_sum[31] = operand_normalized_ieee_a[31];
							final_sum [30:23] = biggest_exponent ;
						end
				end
		else if ((~&exponent_a & ~&exponent_b) & (operand_normalized_ieee_a[22:0] == operand_normalized_ieee_b[22:0]) & (operand_normalized_ieee_a[31] != signB) & (exponent_a == exponent_b) )
						final_sum = 32'b0;
						
			
			
			else
				begin
	 			  
if(operand_normalized_ieee_a[31]==signB)
begin
		//then we simply add the fraction

		sum = fraction_a + fraction_b;// checck blue	
		final_sum[31]=operand_normalized_ieee_a[31];
		// then we check if carry_of_fraction = 1 we add 1 to
		if (sum[24] == 1 )
		begin
			biggest_exponent= biggest_exponent + 1 ;
			sum=sum>>1;
end					
end
else
if (exponent_a > exponent_b)
begin
			sum = fraction_a - fraction_b;// checck blue	
      final_sum[31]=operand_normalized_ieee_a[31];
end
else if (exponent_a < exponent_b)
  begin
    
		sum = fraction_b - fraction_a;// checck blue	
final_sum[31]=signB;
end
else if (fraction_a>=fraction_b)
  begin
    
		sum=fraction_a - fraction_b;
    final_sum[31]=operand_normalized_ieee_a[31];
end
else
  begin
		sum=fraction_b - fraction_a;
	final_sum[31]=signB;
	end
	
//shift the biggest exponent to  normalize the final sum
//logic [24:0] sum_case_zero =sum[24:0];
        if (sum[23]==0)
        for(i =0 ; i<=23;i=i+1)	
        begin
          if(sum[23]==0)
          begin
            sum=sum<<1;
            if (biggest_exponent>=1)
            biggest_exponent=biggest_exponent-1;
          end
        end
 if (sum[24] == 1 )
		begin
			biggest_exponent= biggest_exponent + 1 ;
			sum=sum>>1;
			end     
//final_sum[31]=operand_normalized_ieee_a[31]&signB;
final_sum[30:23]=biggest_exponent;
final_sum[22:0]=sum[22:0];
// chck for under and over flow


		end
		
		
if (biggest_exponent == 0)
			begin
			underflow = 1 ; 
			end
else if (biggest_exponent > 8'd254)
			begin
			overflow = 1 ;
			end
finish = 1 ;
//$display("\n RESULT %b %b\n",sum,final_sum);

/*
overflow<=(biggest_exponent>=8'b11111111);

underflow<=(biggest_exponent==0);
finish=1;
end
*/


end
endmodule
