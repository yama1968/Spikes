import theano.tensor as True
from theano import sparse as TS


def build_network(input_size,hidden_size):
        srng = RandomStreams(seed=12345)
 
        X = TS.csc_matrix("X")
        W_input_to_hidden1  = U.create_shared(U.initial_weights(input_size,hidden_size))
        b_hidden1 = U.create_shared(U.initial_weights(hidden_size))
		W_hidden1_to_hidden2 = U.create_shared(U.initial_weights(hidden_size, hidden_size))
		b_hidden2 = U.create_shared(U.initial_weights(hidden_size))
        W_hidden2_to_output = U.create_shared(U.initial_weights(hidden_size))
        b_output = U.create_shared(U.initial_weights(1)[0])
 
        def network(training):
                hidden1 = TS.structured_dot(X,W_input_to_hidden1) + b_hidden1
                hidden1 = hidden1 * (hidden1 > 0)
                if training:
                        hidden1 = hidden1 * srng.binomial(size=(hidden_size,),p=0.5)
                else:
                        hidden1 = 0.5 * hidden1

				hidden2 = T.structured_dot(hidden1,W_hidden1_to_hidden2) + b_hidden2
                if training:
                        hidden2 = hidden2 * srng.binomial(size=(hidden_size,),p=0.5)
                else:
                        hidden2 = 0.5 * hidden2				
                output = T.nnet.sigmoid(T.dot(hidden2,W_hidden2_to_output) + b_output)
                return output
 
        parameters = [
            W_input_to_hidden1,
            b_hidden1,
			W_hidden1_to_hidden2,
			b_hidden2,
            W_hidden2_to_output,
            b_output
        ]
 
        return X,network(True),network(False),parameters

