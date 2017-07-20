SELECT AVG(salary), mID, position
FROM Staff, Paygrade
WHERE position = 'Manager'
AND Staff.paygrade = Paygrade.paygrade
GROUP BY mID;