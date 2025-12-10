import psycopg2
import pandas as pd

# Konfigurasi koneksi — ganti sesuai setup Anda
conn = psycopg2.connect(
    host="localhost",
    port="5432",
    user="postgres",
    password="postgres",
    dbname="tubes"
)

def get_df(query, params=None):
    """
    Eksekusi SQL query dan return hasil sebagai pandas DataFrame
    """
    df = pd.read_sql_query(query, conn, params=params)
    return df

# Contoh query dasar:

def fetch_students():
  query = """
  SELECT user_id AS student_id, name, gender, region, highest_education, date_of_birth
  FROM user_account
  WHERE role = 'student'
  ORDER BY name;
  """
  return get_df(query)


def fetch_instructors():
  query = """
  SELECT user_id AS instructor_id, name, department
  FROM user_account
  WHERE role = 'instructor'
  ORDER BY name;
  """
  return get_df(query)

def fetch_presentations():
    query = """
    SELECT p.presentation_id, p.semester, p.year,
           m.module_code, m.module_name,
           i.name AS instructor_name,
           i.user_id AS instructor_id
    FROM presentation p
      JOIN course_module m ON p.module_id = m.module_id
      JOIN user_account i ON p.instructor_id = i.user_id
    ORDER BY p.year DESC, p.semester ASC;
    """
    return get_df(query)

def fetch_enrollment(presentation_id):
    query = """
    SELECT e.enrollment_id, e.presentation_id, s.user_id AS student_id, s.name,
           e.studied_credits, e.final_result
    FROM enrollment e
      JOIN user_account s ON e.student_id = s.user_id
    WHERE e.presentation_id = %s AND s.role = 'student'
    ORDER BY s.name;
    """
    return get_df(query, params=(presentation_id,))

def fetch_assessments(presentation_id):
  query = """
  SELECT a.assessment_id, a.assessment_name, a.weight
  FROM assessment a
  WHERE a.presentation_id = %s
  ORDER BY a.assessment_id;
  """
  return get_df(query, params=(presentation_id,))

def fetch_student_scores(enrollment_id):
    query = """
    SELECT sa.student_assessment_id, a.assessment_id, a.assessment_name, sa.score, a.weight
    FROM student_assessment sa
      JOIN assessment a ON sa.assessment_id = a.assessment_id
    WHERE sa.enrollment_id = %s;
    """
    return get_df(query, params=(enrollment_id,))

def fetch_vle_activity(enrollment_id):
    query = """
    SELECT sva.vle_id, v.vle_type, v.title, sva.activity_date, sva.clicks
    FROM student_vle_activity sva
      JOIN vle_item v ON sva.vle_id = v.vle_id
    WHERE sva.enrollment_id = %s
    ORDER BY sva.activity_date;
    """
    return get_df(query, params=(enrollment_id,))

# ===== Tambahan helper untuk analitik =====

def fetch_enrollments_all():
    query = """
    SELECT e.enrollment_id, e.presentation_id, e.student_id,
      e.final_result, e.studied_credits
    FROM enrollment e;
    """
    return get_df(query)


def fetch_final_scores_all(presentation_id=None):
    """Hitung skor akhir (weighted) per enrollment: SUM(score*weight)/SUM(weight)."""
    params = tuple()
    where = ""
    if presentation_id is not None:
        where = "WHERE e.presentation_id = %s"
        params = (presentation_id,)
    query = f"""
    SELECT e.enrollment_id,
           e.presentation_id,
           e.student_id,
           CASE WHEN NULLIF(SUM(a.weight),0) IS NOT NULL
                THEN SUM(sa.score * a.weight)::DECIMAL / NULLIF(SUM(a.weight),0)
                ELSE NULL END AS final_score
    FROM enrollment e
      JOIN student_assessment sa ON sa.enrollment_id = e.enrollment_id
      JOIN assessment a ON a.assessment_id = sa.assessment_id
    {where}
    GROUP BY e.enrollment_id, e.presentation_id, e.student_id;
    """
    return get_df(query, params=params if params else None)


def fetch_final_results_distribution(presentation_id):
    query = """
    SELECT final_result, COUNT(*) AS cnt
    FROM enrollment
    WHERE presentation_id = %s
    GROUP BY final_result
    ORDER BY cnt DESC;
    """
    return get_df(query, params=(presentation_id,))


def fetch_total_clicks_all(presentation_id=None):
    params = tuple()
    where = ""
    if presentation_id is not None:
        where = "WHERE e.presentation_id = %s"
        params = (presentation_id,)
    query = f"""
    SELECT e.enrollment_id,
           e.presentation_id,
           COALESCE(SUM(sva.clicks),0) AS total_clicks
    FROM student_vle_activity sva
      RIGHT JOIN enrollment e ON e.enrollment_id = sva.enrollment_id
    {where}
    GROUP BY e.enrollment_id, e.presentation_id;
    """
    return get_df(query, params=params if params else None)


def fetch_vle_avg_timeline_by_presentation(presentation_id):
    query = """
    SELECT sva.activity_date::date AS activity_date,
           AVG(sva.clicks) AS avg_clicks
    FROM student_vle_activity sva
      JOIN enrollment e ON e.enrollment_id = sva.enrollment_id
    WHERE e.presentation_id = %s
    GROUP BY activity_date
    ORDER BY activity_date;
    """
    return get_df(query, params=(presentation_id,))


def fetch_assessment_scores_by_enrollment(enrollment_id):
    query = """
    SELECT a.assessment_id,
           a.assessment_name,
           a.weight,
           sa.score
    FROM assessment a
      LEFT JOIN student_assessment sa
        ON sa.assessment_id = a.assessment_id
       AND sa.enrollment_id = %s
    WHERE a.presentation_id = (
        SELECT presentation_id FROM enrollment WHERE enrollment_id = %s
    )
    ORDER BY a.assessment_id;
    """
    return get_df(query, params=(enrollment_id, enrollment_id))


def fetch_students_by_module_counts():
    query = """
    SELECT m.module_code,
           COUNT(*) AS student_count
    FROM enrollment e
      JOIN presentation p ON p.presentation_id = e.presentation_id
      JOIN course_module m ON m.module_id = p.module_id
    GROUP BY m.module_code
    ORDER BY student_count DESC;
    """
    return get_df(query)
