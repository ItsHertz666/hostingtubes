import streamlit as st
import pandas as pd
import plotly.express as px

from config import (
    fetch_students,
    fetch_instructors,
    fetch_presentations,
    fetch_enrollment,
    fetch_assessments,
    fetch_student_scores,
    fetch_vle_activity,
    fetch_enrollments_all,
    fetch_final_scores_all,
    fetch_final_results_distribution,
    fetch_total_clicks_all,
    fetch_vle_avg_timeline_by_presentation,
    fetch_assessment_scores_by_enrollment,
    fetch_students_by_module_counts,
)

st.set_page_config(page_title="VLE Dashboard", layout="wide")

st.title("📘 VLE Dashboard")

"""
I'll simplify and fix the dark styling to ensure readability.
"""
st.markdown(
    """
    <style>
        /* Layout spacing */
        .block-container { padding-top: 3rem; }

        /* Headings */
        h1, .stMarkdown h1 { font-size: 2.2rem; line-height: 2.8rem; margin-top: 0.2rem; }

        /* Metric cards: high contrast in dark */
        html[data-theme="dark"] .stMetric { background: #121826; border: 1px solid #1f3c88; border-radius: 12px; }
        html[data-theme="dark"] .stMetric > div { color: #e6edf7; }
        html[data-theme="light"] .stMetric { background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 12px; }

        /* Sidebar: dark friendly */
        html[data-theme="dark"] section[data-testid="stSidebar"] { background-color: #0f1523; }

        /* Tabs accent */
        .stTabs [aria-selected="true"] { border-bottom: 3px solid #1f3c88; }
    </style>
    """,
    unsafe_allow_html=True,
)

# Set Plotly template based on current theme
try:
        base_theme = st.get_option("theme.base")
        import plotly.express as _px
        _px.defaults.template = "plotly_dark" if str(base_theme).lower() == "dark" else "plotly"
except Exception:
        pass

# UK-inspired palette (blue, red, off-white, navy)
UK_PALETTE = ["#1f3c88", "#e63946", "#f5f7fa", "#14213d", "#2a9d8f"]

sidebar = st.sidebar
page = sidebar.selectbox("Select Page", ["Overview", "Classes", "Students", "Analytics", "Instructors"])

# Cache wrappers to speed up UI (5 minutes)
@st.cache_data(ttl=300)
def c_fetch_students():
    return fetch_students()

@st.cache_data(ttl=300)
def c_fetch_presentations():
    return fetch_presentations()

@st.cache_data(ttl=300)
def c_fetch_enrollment(pres_id: int):
    return fetch_enrollment(pres_id)

@st.cache_data(ttl=300)
def c_fetch_enrollments_all():
    return fetch_enrollments_all()

@st.cache_data(ttl=300)
def c_fetch_final_scores_all(pres_id=None):
    return fetch_final_scores_all(pres_id)

@st.cache_data(ttl=300)
def c_fetch_final_results_distribution(pres_id: int):
    return fetch_final_results_distribution(pres_id)

@st.cache_data(ttl=300)
def c_fetch_total_clicks_all(pres_id=None):
    return fetch_total_clicks_all(pres_id)

@st.cache_data(ttl=300)
def c_fetch_vle_avg_timeline_by_presentation(pres_id: int):
    return fetch_vle_avg_timeline_by_presentation(pres_id)

@st.cache_data(ttl=300)
def c_fetch_assessment_scores_by_enrollment(enr_id: int):
    return fetch_assessment_scores_by_enrollment(enr_id)

@st.cache_data(ttl=300)
def c_fetch_students_by_module_counts():
    return fetch_students_by_module_counts()

# Now that cache wrappers exist, set up global filters
df_presentations_all = c_fetch_presentations()
df_instructors_all = fetch_instructors()
sem_options = (df_presentations_all["semester"].astype(str) + " " + df_presentations_all["year"].astype(str)).unique().tolist()
instr_options = sorted(df_presentations_all["instructor_name"].dropna().unique().tolist())
selected_sems = sidebar.multiselect("Filter by Semester", sem_options, default=sem_options)
selected_instrs = sidebar.multiselect("Filter by Instructor", instr_options, default=instr_options)

def apply_global_filters(df_pres: pd.DataFrame, df_enr: pd.DataFrame):
    if df_pres.empty:
        return df_pres, df_enr
    df_pres_f = df_pres.copy()
    df_pres_f["sem_label"] = df_pres_f["semester"].astype(str) + " " + df_pres_f["year"].astype(str)
    df_pres_f = df_pres_f[df_pres_f["sem_label"].isin(selected_sems) & df_pres_f["instructor_name"].isin(selected_instrs)]
    if df_enr is not None and not df_enr.empty:
        df_enr_f = df_enr[df_enr["presentation_id"].isin(df_pres_f["presentation_id"])]
    else:
        df_enr_f = df_enr
    return df_pres_f.drop(columns=["sem_label"]), df_enr_f

if page == "Overview":
    st.header("Overview / Summary")

    df_students = c_fetch_students()
    df_presentations = c_fetch_presentations()
    df_enroll_all = c_fetch_enrollments_all()
    df_presentations, df_enroll_all = apply_global_filters(df_presentations, df_enroll_all)
    df_instructors = fetch_instructors()

    st.subheader("Total Users & Entities")
    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Students", len(df_students))
    col2.metric("Classes", len(df_presentations))
    # module count
    module_count = df_presentations["module_code"].nunique()
    col3.metric("Modules", module_count)
    col4.metric("Instructors", df_instructors.shape[0] if not df_instructors.empty else df_presentations["instructor_name"].nunique())

    c1, c2 = st.columns(2)
    with c1:
        st.subheader("Students by Region")
        fig = px.histogram(df_students, x="region", title="Distribusi Mahasiswa per Region", color_discrete_sequence=UK_PALETTE)
        st.plotly_chart(fig, use_container_width=True)
    with c2:
        st.subheader("Students by Gender")
        fig2 = px.pie(df_students, names="gender", title="Distribusi Gender Mahasiswa", color_discrete_sequence=UK_PALETTE)
        st.plotly_chart(fig2, use_container_width=True)

    st.subheader("Students per Module")
    df_by_mod = fetch_students_by_module_counts()
    if not df_by_mod.empty:
        figm = px.bar(df_by_mod, x="module_code", y="student_count", title="Jumlah Mahasiswa per Modul", color_discrete_sequence=UK_PALETTE)
        st.plotly_chart(figm, use_container_width=True)
    else:
        st.info("Belum ada data enrollment untuk menghitung distribusi per modul.")

    st.subheader("Students per Semester")
    if not df_enroll_all.empty and not df_presentations.empty:
        df_sem = df_enroll_all.merge(df_presentations[["presentation_id", "semester", "year"]], on="presentation_id", how="left")
        df_sem["semester_label"] = df_sem["semester"].astype(str) + " " + df_sem["year"].astype(str)
        sem_counts = df_sem.groupby("semester_label").size().reset_index(name="student_count")
        fig_sem = px.bar(sem_counts, x="semester_label", y="student_count", title="Jumlah Mahasiswa per Semester", color_discrete_sequence=UK_PALETTE)
        st.plotly_chart(fig_sem, use_container_width=True)

    st.subheader("Students per Instructor")
    if not df_enroll_all.empty and not df_presentations.empty:
        df_instr = df_enroll_all.merge(df_presentations[["presentation_id", "instructor_name"]], on="presentation_id", how="left")
        instr_counts = df_instr.groupby("instructor_name").size().reset_index(name="student_count")
        fig_instr = px.bar(instr_counts, x="instructor_name", y="student_count", title="Jumlah Mahasiswa per Dosen", color_discrete_sequence=UK_PALETTE)
        st.plotly_chart(fig_instr, use_container_width=True)

    st.subheader("Demografi: Usia Mahasiswa")
    if not df_students.empty and "date_of_birth" in df_students.columns:
        today = pd.Timestamp.today().normalize()
        ages = (today - pd.to_datetime(df_students["date_of_birth"]).dt.normalize()).dt.days // 365
        df_age = pd.DataFrame({"age": ages})
        a1, a2 = st.columns(2)
        with a1:
            st.metric("Median Age", int(df_age["age"].median()))
        with a2:
            st.metric("Avg Age", round(float(df_age["age"].mean()), 1))
        fig_age = px.histogram(df_age, x="age", nbins=15, title="Distribusi Usia Mahasiswa", color_discrete_sequence=UK_PALETTE)
        st.plotly_chart(fig_age, use_container_width=True)

    st.subheader("Engagement KPI (Global)")
    df_clicks_all = c_fetch_total_clicks_all()
    if not df_clicks_all.empty and not df_enroll_all.empty:
        df_clicks_f = df_clicks_all[df_clicks_all["presentation_id"].isin(df_presentations["presentation_id"])].merge(df_enroll_all[["enrollment_id","student_id"]], on="enrollment_id", how="left")
        avg_clicks_per_student = df_clicks_f.groupby("student_id")["total_clicks"].sum().mean()
        total_clicks = int(df_clicks_f["total_clicks"].sum())
        k1, k2 = st.columns(2)
        k1.metric("Avg Clicks per Student", round(avg_clicks_per_student, 1))
        k2.metric("Total Clicks (Filtered)", total_clicks)

elif page == "Classes":
    st.header("Classes / Presentations")
    df_pres = c_fetch_presentations()
    df_pres, _ = apply_global_filters(df_pres, None)
    sel = st.selectbox("Select a class", df_pres["presentation_id"].astype(str) + " – " + df_pres["module_code"] + " (" + df_pres["semester"].astype(str) + " " + df_pres["year"].astype(str) + ")")
    pres_id = int(sel.split(" – ")[0])

    df_enroll = c_fetch_enrollment(pres_id)
    st.subheader("Students in Class")
    st.dataframe(df_enroll)

    # Jika ada assessment → nilai & distribusi
    df_scores = []
    for eid in df_enroll["enrollment_id"]:
        df = fetch_student_scores(eid)
        df["enrollment_id"] = eid
        df_scores.append(df)
    if df_scores:
        df_all_scores = pd.concat(df_scores, ignore_index=True)
        st.subheader("Assessment Scores Distribution")
        fig3 = px.histogram(df_all_scores, x="score", nbins=20, title="Distribusi Nilai", color_discrete_sequence=UK_PALETTE)
        st.plotly_chart(fig3)

    # Final score (weighted) per enrollment
    df_final = c_fetch_final_scores_all(pres_id)
    if not df_final.empty:
        # KPI metrics
        df_clicks_p = c_fetch_total_clicks_all(pres_id)
        avg_score = round(df_final["final_score"].dropna().mean(), 2) if not df_final.empty else None
        pass_rate = None
        if not df_enroll.empty and "final_result" in df_enroll.columns:
            pass_rate = round(
                (df_enroll["final_result"].astype(str).str.lower().isin(["pass", "distinction"]).mean()) * 100,
                1,
            )
        total_clicks_avg = round(df_clicks_p["total_clicks"].mean(), 1) if not df_clicks_p.empty else 0

        m1, m2, m3 = st.columns(3)
        m1.metric("Avg Final Score", avg_score if avg_score is not None else "-")
        m2.metric("Pass Rate", f"{pass_rate}%" if pass_rate is not None else "-")
        m3.metric("Avg Total Clicks", total_clicks_avg)

        c1, c2 = st.columns(2)
        with c1:
            st.subheader("Final Scores (Weighted)")
            f1 = px.histogram(df_final, x="final_score", nbins=20, title="Sebaran Skor Akhir", color_discrete_sequence=UK_PALETTE)
            st.plotly_chart(f1, use_container_width=True)
        with c2:
            st.subheader("Final Result Distribution")
            df_res = c_fetch_final_results_distribution(pres_id)
            f2 = px.pie(df_res, names="final_result", values="cnt", title="Final Result", color_discrete_sequence=UK_PALETTE)
            st.plotly_chart(f2, use_container_width=True)

    # VLE average timeline (by date)
    df_tl = c_fetch_vle_avg_timeline_by_presentation(pres_id)
    if not df_tl.empty:
        st.subheader("Rata-rata Klik VLE per Tanggal")
        f3 = px.line(df_tl, x="activity_date", y="avg_clicks", markers=True, color_discrete_sequence=UK_PALETTE)
        st.plotly_chart(f3, use_container_width=True)

    # ================= Assessments Section =================
    st.subheader("Assessments Overview")
    df_ass_w = fetch_assessments(pres_id)
    if not df_ass_w.empty:
        cA, cB = st.columns(2)
        with cA:
            donut = px.pie(df_ass_w, names="assessment_name", values="weight", hole=0.5,
                           title="Komposisi Bobot Assessment", color_discrete_sequence=UK_PALETTE)
            st.plotly_chart(donut, use_container_width=True)
        with cB:
            # Completion rate per assessment: submitted vs missing
            enroll_ids = df_enroll["enrollment_id"].tolist()
            submitted_counts = []
            for aid in df_ass_w["assessment_id"].tolist():
                # build submitted count by checking student_assessment fetched earlier or re-fetch
                cnt = 0
                for eid in enroll_ids:
                    s = fetch_student_scores(eid)
                    if not s.empty and (s["assessment_id"] == aid).any():
                        cnt += 1
                submitted_counts.append(cnt)
            comp_df = pd.DataFrame({
                "assessment_name": df_ass_w["assessment_name"],
                "submitted": submitted_counts,
            })
            comp_df["missing"] = len(enroll_ids) - comp_df["submitted"]
            comp_melt = comp_df.melt(id_vars=["assessment_name"], value_vars=["submitted","missing"],
                                     var_name="status", value_name="count")
            bar_comp = px.bar(comp_melt, x="assessment_name", y="count", color="status",
                              title="Completion Rate per Assessment", barmode="stack",
                              color_discrete_sequence=UK_PALETTE)
            st.plotly_chart(bar_comp, use_container_width=True)

        st.subheader("Score vs Weight")
        # Collect all student scores for this class
        df_scores_all = []
        for eid in df_enroll["enrollment_id"]:
            sc = fetch_student_scores(eid)
            if not sc.empty:
                sc["enrollment_id"] = eid
                df_scores_all.append(sc)
        if df_scores_all:
            df_scores_all = pd.concat(df_scores_all, ignore_index=True)
            # Merge final_result for coloring context
            df_scores_all = df_scores_all.merge(df_enroll[["enrollment_id","final_result"]], on="enrollment_id", how="left")
            scatter_sw = px.scatter(df_scores_all, x="weight", y="score", color="final_result",
                                    title="Skor vs Bobot Assessment", color_discrete_sequence=UK_PALETTE)
            st.plotly_chart(scatter_sw, use_container_width=True)
        else:
            st.info("Belum ada skor assessment untuk kelas ini.")

        st.subheader("Assessment Status Grid (Per Student)")
        # Build student x assessment matrix with Submitted/Missing
        grid = []
        assess_ids = df_ass_w[["assessment_id","assessment_name"]].values.tolist()
        for _, row in df_enroll.iterrows():
            eid = row["enrollment_id"]
            name = row["name"]
            sc = fetch_student_scores(eid)
            for aid, aname in assess_ids:
                submitted = (not sc.empty) and (sc["assessment_id"] == aid).any()
                grid.append({"student": name, "assessment": aname, "status": "Submitted" if submitted else "Missing"})
        df_grid = pd.DataFrame(grid)
        if not df_grid.empty:
            # Display as pivot-like table
            pivot = df_grid.pivot_table(index="student", columns="assessment", values="status", aggfunc="first")
            st.dataframe(pivot)
        else:
            st.info("Belum ada data status assessment.")
    else:
        st.info("Tidak ada assessment untuk kelas ini.")

elif page == "Students":
    st.header("Student Profile & Activity")

    df_students = fetch_students()
    sel = st.selectbox("Pick a student", df_students["student_id"].astype(str) + " – " + df_students["name"])
    stud_id = int(sel.split(" – ")[0])

    tab_info, tab_enroll, tab_activity, tab_assess = st.tabs(["Info", "Enrollments", "Activity", "Assessments"])

    with tab_info:
        st.subheader("Basic Info")
        rec = df_students[df_students["student_id"] == stud_id].iloc[0]
                # Compute age
        age_val = None
        try:
                        dob = pd.to_datetime(rec.get("date_of_birth"))
                        age_val = int((pd.Timestamp.today().normalize() - dob.normalize()).days // 365)
        except Exception:
                        pass
                # Profile card (dark-themed with UK accents)
        st.markdown(
                        f"""
                        <div style="background:#0b1220;border:1px solid #1f3c88;border-radius:14px;padding:16px;color:#f5f7fa;">
                            <div style="display:flex;align-items:center;gap:16px;">
                                <div style="width:56px;height:56px;border-radius:50%;background:#14213d;display:flex;align-items:center;justify-content:center;color:#f5f7fa;font-weight:700;">
                                    {str(rec.get('name',''))[:1]}
                                </div>
                                <div>
                                    <div style="font-size:1.2rem;font-weight:700;color:#f5f7fa;">{rec.get('name','')}</div>
                                    <div style="color:#a9b4c7;">ID: {int(rec.get('student_id')) if pd.notna(rec.get('student_id')) else '-'} • Age: {age_val if age_val is not None else '-'} </div>
                                </div>
                            </div>
                            <div style="display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px;margin-top:14px;">
                                <div style="background:#10192b;border:1px solid #14213d;border-radius:10px;padding:10px;">
                                    <div style="color:#a9b4c7;font-size:0.85rem;">Gender</div>
                                    <div style="color:#f5f7fa;font-weight:600;">{rec.get('gender','-')}</div>
                                </div>
                                <div style="background:#10192b;border:1px solid #14213d;border-radius:10px;padding:10px;">
                                    <div style="color:#a9b4c7;font-size:0.85rem;">Region</div>
                                    <div style="color:#f5f7fa;font-weight:600;">{rec.get('region','-')}</div>
                                </div>
                                <div style="background:#10192b;border:1px solid #14213d;border-radius:10px;padding:10px;">
                                    <div style="color:#a9b4c7;font-size:0.85rem;">Highest Education</div>
                                    <div style="color:#f5f7fa;font-weight:600;">{rec.get('highest_education','-')}</div>
                                </div>
                                <div style="background:#10192b;border:1px solid #14213d;border-radius:10px;padding:10px;">
                                    <div style="color:#a9b4c7;font-size:0.85rem;">Date of Birth</div>
                                    <div style="color:#f5f7fa;font-weight:600;">{rec.get('date_of_birth','-')}</div>
                                </div>
                            </div>
                        </div>
                        """,
                        unsafe_allow_html=True,
                )

    with tab_enroll:
        st.subheader("Enrollments")
    # Ambil semua enrollment & gabungkan dengan kelas
    df_pres_all = fetch_presentations()
    df_enr_all = c_fetch_enrollments_all()
    df_pres_all, df_enr_all = apply_global_filters(df_pres_all, df_enr_all)
    df_enr = df_enr_all[df_enr_all["student_id"] == stud_id]
    if not df_enr.empty:
            df_enr = df_enr.merge(df_pres_all, on="presentation_id", how="left")
            st.dataframe(df_enr[["enrollment_id","module_code","module_name","semester","year","final_result","studied_credits"]])
    else:
        st.write("Tidak ada data enrollment.")

    with tab_activity:
        st.subheader("VLE Activity")
        # Pilih enrollment spesifik (jika ada)
        df_pres_all = fetch_presentations()
        df_enr_all = c_fetch_enrollments_all()
        df_pres_all, df_enr_all = apply_global_filters(df_pres_all, df_enr_all)
        df_enr_s = df_enr_all[df_enr_all["student_id"] == stud_id].merge(df_pres_all, on="presentation_id", how="left")
        if not df_enr_s.empty:
            enr_labels = df_enr_s.apply(lambda r: f"{int(r['enrollment_id'])} – {r['module_code']} ({r['semester']} {r['year']})", axis=1)
            sel_enr = st.selectbox("Pilih Enrollment", enr_labels)
            first_enrollment_id = int(str(sel_enr).split(" – ")[0])

            c1, c2 = st.columns(2)
            with c1:
                df_vle = fetch_vle_activity(first_enrollment_id)
                if not df_vle.empty:
                    t_clicks = int(df_vle["clicks"].sum())
                    days = df_vle["activity_date"].astype("datetime64[ns]").dt.date.nunique()
                    weeks = max(1, days // 7)
                    engagement_per_week = round(t_clicks / weeks, 2)
                    mc1, mc2 = st.columns(2)
                    mc1.metric("Total Klik", t_clicks)
                    mc2.metric("Engagement / Minggu", engagement_per_week)
                    fig4 = px.line(df_vle.sort_values("activity_date"), x="activity_date", y="clicks", color="vle_type", color_discrete_sequence=UK_PALETTE,
                                  title="Timeline Aktivitas VLE")
                    st.plotly_chart(fig4, use_container_width=True)
                else:
                    st.write("Tidak ada data aktivitas VLE untuk enrollment ini.")
            with c2:
                df_scores = c_fetch_final_scores_all()
                df_clicks = c_fetch_total_clicks_all()
                if not df_scores.empty and not df_clicks.empty:
                    df_sc = df_scores.merge(df_clicks, on=["enrollment_id", "presentation_id"], how="left")
                    df_sc_s = df_sc[df_sc["enrollment_id"] == first_enrollment_id]
                    if not df_sc_s.empty:
                        st.write("Ringkasan Skor vs Klik")
                        st.dataframe(df_sc_s[["final_score", "total_clicks"]])
        else:
            st.write("Tidak ada enrollment untuk mahasiswa ini.")

    with tab_assess:
        st.subheader("Assessments & Scores")
        df_pres_all = fetch_presentations()
        df_enr_all = c_fetch_enrollments_all()
        df_pres_all, df_enr_all = apply_global_filters(df_pres_all, df_enr_all)
        df_enr_s = df_enr_all[df_enr_all["student_id"] == stud_id].merge(df_pres_all, on="presentation_id", how="left")
        if not df_enr_s.empty:
            enr_labels = df_enr_s.apply(lambda r: f"{int(r['enrollment_id'])} – {r['module_code']} ({r['semester']} {r['year']})", axis=1)
            sel_enr2 = st.selectbox("Pilih Enrollment untuk Assessment", enr_labels)
            enr_id2 = int(str(sel_enr2).split(" – ")[0])
            df_ass = c_fetch_assessment_scores_by_enrollment(enr_id2)
            if not df_ass.empty:
                st.dataframe(df_ass)
                # Visual: bar score vs weight
                if "score" in df_ass.columns:
                    b1, b2 = st.columns(2)
                    with b1:
                        bar1 = px.bar(df_ass.fillna({"score": 0}), x="assessment_name", y="score", title="Skor per Assessment", color_discrete_sequence=UK_PALETTE)
                        st.plotly_chart(bar1, use_container_width=True)
                    with b2:
                        bar2 = px.bar(df_ass.fillna({"weight": 0}), x="assessment_name", y="weight", title="Bobot per Assessment", color_discrete_sequence=UK_PALETTE)
                        st.plotly_chart(bar2, use_container_width=True)
            else:
                st.write("Belum ada data assessment.")

elif page == "Analytics":
    st.header("Learning Analytics & Insights")

    # Scatter: total clicks vs final_score (semua enrollment)
    df_scores = c_fetch_final_scores_all()
    df_clicks = c_fetch_total_clicks_all()
    if not df_scores.empty and not df_clicks.empty:
        df_pres_f, _ = apply_global_filters(c_fetch_presentations(), None)
        df_sc = df_scores.merge(df_clicks, on=["enrollment_id", "presentation_id"], how="left")
        df_sc = df_sc[df_sc["presentation_id"].isin(df_pres_f["presentation_id"])]
        fig = px.scatter(df_sc, x="total_clicks", y="final_score",
                         title="Total Klik VLE vs Skor Akhir")
        st.plotly_chart(fig, use_container_width=True)
        # Correlation metric
        try:
            corr = df_sc[["total_clicks", "final_score"]].dropna().corr().iloc[0, 1]
            st.metric("Correlation (Clicks vs Score)", f"{corr:.2f}")
        except Exception:
            pass
    else:
        st.info("Data skor atau klik belum tersedia.")

    # Boxplot by gender
    df_students = c_fetch_students()
    if not df_scores.empty:
        df_enrollments_all = c_fetch_enrollments_all()
        df_sg = df_scores.merge(df_enrollments_all, on=["enrollment_id", "presentation_id", "student_id"], how="left")
        df_sg = df_sg.merge(df_students, on="student_id", how="left")
        c1, c2 = st.columns(2)
        with c1:
            fb = px.box(df_sg.dropna(subset=["final_score", "gender"]), x="gender", y="final_score", title="Skor Akhir per Gender", color_discrete_sequence=UK_PALETTE)
            st.plotly_chart(fb, use_container_width=True)
        with c2:
            fr = px.box(df_sg.dropna(subset=["final_score", "region"]), x="region", y="final_score", title="Skor Akhir per Region", color_discrete_sequence=UK_PALETTE)
            st.plotly_chart(fr, use_container_width=True)

    # Trend enrollment & withdrawn per semester/year
    df_pres = c_fetch_presentations()
    df_enr_all = c_fetch_enrollments_all()
    df_pres, df_enr_all = apply_global_filters(df_pres, df_enr_all)
    if not df_pres.empty and not df_enr_all.empty:
        df_enr_tr = df_enr_all.merge(df_pres[["presentation_id", "semester", "year"]], on="presentation_id", how="left")
        df_enr_tr["sem_label"] = df_enr_tr["semester"].astype(str) + " " + df_enr_tr["year"].astype(str)
        trend = df_enr_tr.groupby("sem_label").size().reset_index(name="enrolled")
        withdraw = df_enr_tr[df_enr_tr["final_result"].astype(str).str.lower().eq("withdrawn")].groupby("sem_label").size().reset_index(name="withdrawn")
        tdf = trend.merge(withdraw, on="sem_label", how="left").fillna(0)
        tl = px.line(tdf, x="sem_label", y=["enrolled", "withdrawn"], title="Trend Enrollment vs Withdrawn per Semester", color_discrete_sequence=UK_PALETTE)
        st.plotly_chart(tl, use_container_width=True)

    # Distribusi bobot assessment
    st.subheader("Distribusi Bobot Assessment per Kelas")
    sel2 = st.selectbox("Pilih kelas untuk melihat bobot assessment", df_pres["presentation_id"].astype(str) + " – " + df_pres["module_code"] + " (" + df_pres["semester"].astype(str) + " " + df_pres["year"].astype(str) + ")")
    pid2 = int(sel2.split(" – ")[0])
    df_ass_w = fetch_assessments(pid2)
    if not df_ass_w.empty:
        hw = px.histogram(df_ass_w, x="weight", nbins=10, title="Distribusi Bobot Assessment", color_discrete_sequence=UK_PALETTE)
        st.plotly_chart(hw, use_container_width=True)
    else:
        st.write("Tidak ada data assessment untuk kelas ini.")

elif page == "Instructors":
    st.header("Instructor / Pengajar")
    df_pres = c_fetch_presentations()
    if df_pres.empty:
        st.info("Belum ada data presentasi.")
    else:
        instr_names = sorted(df_pres["instructor_name"].dropna().unique().tolist())
        instr = st.selectbox("Pilih Instructor", instr_names)
        df_instr_classes = df_pres[df_pres["instructor_name"] == instr]
        st.subheader(f"Kelas yang diaampu {instr}")
        st.dataframe(df_instr_classes[["module_code", "module_name", "semester", "year"]])

        # Statistik per kelas: rata-rata skor & pass rate
        df_scores = c_fetch_final_scores_all()
        df_enr = c_fetch_enrollments_all()
        if not df_scores.empty and not df_enr.empty:
            df_join = df_instr_classes[["presentation_id", "module_code"]].merge(df_scores, on="presentation_id", how="left")
            df_pass = df_enr[df_enr["presentation_id"].isin(df_instr_classes["presentation_id"])].copy()
            # pass rate: final_result == 'Pass' or similar
            df_pass["is_pass"] = df_pass["final_result"].str.lower().isin(["pass", "distinction"]).astype(int)
            pass_rate = df_pass.groupby("presentation_id")["is_pass"].mean().reset_index(name="pass_rate")
            df_stat = df_join.groupby(["presentation_id", "module_code"]).agg(avg_score=("final_score", "mean")).reset_index()
            df_stat = df_stat.merge(pass_rate, on="presentation_id", how="left")

            # KPIs for the instructor
            m1, m2, m3 = st.columns(3)
            m1.metric("Jumlah Kelas", int(df_instr_classes.shape[0]))
            m2.metric("Rata Skor", round(df_stat["avg_score"].dropna().mean(), 2) if not df_stat.empty else "-")
            m3.metric("Pass Rate Rata2", f"{round(df_stat['pass_rate'].fillna(0).mean()*100,1)}%" if "pass_rate" in df_stat else "-")

            st.subheader("Perbandingan Kelas: Skor & Pass Rate")
            figi = px.bar(df_stat, x="module_code", y=["avg_score", "pass_rate"], barmode="group", color_discrete_sequence=UK_PALETTE)
            st.plotly_chart(figi, use_container_width=True)

