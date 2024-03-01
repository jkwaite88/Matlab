%HW1

w =  [1.;2];
b = 1.5;
X = [[1., -2., -1.]; [3., 0.5, -3.2]];
Y = [1, 1, 0];
[grads, cost] = propagate(w, b, X, Y);

f = [0 3 4; 1 6 4]
g = norm(x)


function [grads, cost] =propagate(w, b, X, Y)
    m = size(X,2);
    Z = w.'*X + b;
    A = sigmoid(Z);
    L = -(Y.*log(A) + (1-Y).*log(1-A));
    cost = 1/m*sum(L);
    dZ = A-Y;
    dw = X*dZ.';
    db = 1/m*sum(dZ);
    grads ={dw, db};

end

function s =sigmoid(z)
    s = 1./(1+exp(-z));
end