-- Q1. Find all the doctors who treated patient for "Diabetes"

select d.doctor_id, fname, lname, gender, Illness, patient_id from doctor d 
join worker w on d.D_Worker_ID = w.Worker_ID
join diagnosis de on de.Doctor_ID= d.Doctor_ID
where Illness= 'Diabetes';

-- Q2. List the details of all patients who have been prescribed "B205"   medication_id mp, patient_id mp, patient_id p
select * from patient p
join medication_prescribed mp on p.Patient_ID=mp.Patient_ID
join medication m on mp.Medication_ID = m.Medication_ID
where m.Medication_ID ='B205';

-- Q3. Find the total number of workers in each department

select d.department_id, count(w.worker_id) from department d
join doctor doc on d.Department_ID=doc.Department_ID
join worker w on w.Worker_ID=doc.D_Worker_ID
group by d.Department_ID;

-- Q4. Retrieve the names and phone numbers of patients who have been diagnosed with 'diabetes'
select p.fname, p.lname,p.telephone from patient p 
join diagnosis d on p.Patient_ID=d.Patient_ID
where Illness='Diabetes';

-- Q5. Get the IDs and names of all doctors who work in ER department 

select d.doctor_id, w.fname as Doctor_firstname, w.lname as doctor_lastname from doctor d 
join worker w on w.Worker_ID = d.D_Worker_ID
where d.Department_ID = 'ER';

-- Q6. Find the total salary expenditure of all workers 

select sum(salary) as total_salary_expenditure from worker;

-- Q7. list all cafeteria staff along with their job position and the food type served in their assigned cafeteria.

select cs.staff_id, s.job_title, cs.position, c.food_type from cafeteria_staff cs
join staff s on s.Staff_ID=cs.Staff_ID
join cafeteria c on cs.Cafeteria_ID=c.Cafeteria_ID

-- Q8. Show details of patients along with medication they are prescribed, even if no medication has been prescribed
select * from patient p 
left join medication_prescribed mp on p.patient_id = mp.patient_id 
left join medication m on mp.medication_id=m.medication_id

-- Q 9. Find the average age of patients diagnosed with "Flu"
select *, avg(p.age) from patient p
join diagnosis d on p.patient_id = d.patient_id
where illness = 'Flu'  