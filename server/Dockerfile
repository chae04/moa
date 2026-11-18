# [역할] 서버를 컨테이너 이미지로 빌드 (Railway가 이 파일을 보고 빌드·실행)
# 멀티 스테이지: 1단계(JDK)에서 jar를 만들고, 2단계(JRE)에는 jar만 복사 → 최종 이미지가 작고 소스·빌드도구가 없음

# ---- 1단계: 빌드 ----
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# 의존성 관련 파일만 먼저 복사 → 소스만 바뀌었을 때는 의존성 다운로드 단계를 캐시로 건너뜀
COPY gradlew settings.gradle.kts build.gradle.kts ./
COPY gradle gradle
RUN chmod +x gradlew && ./gradlew dependencies --no-daemon > /dev/null

# 소스 복사 후 실행용 jar 하나만 생성 (bootJar: 테스트 실행 안 함, -plain.jar도 안 만듦)
COPY src src
RUN ./gradlew bootJar --no-daemon

# ---- 2단계: 실행 ----
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/build/libs/*.jar app.jar

# 한국 시간 기준으로 실행 (createdAt 등 LocalDateTime.now()가 서버 시간대를 따름)
# 메모리 제한 (Railway는 메모리 사용량으로 과금):
# -Xmx256m: 힙 최대 256MB (기본값은 컨테이너 메모리의 1/4이라 큰 서버에서는 필요 이상으로 잡음)
# -XX:+UseSerialGC: 가장 단순한 GC. 혼자 쓰는 작은 서버에서는 G1보다 메모리를 덜 씀
ENTRYPOINT ["java", "-Duser.timezone=Asia/Seoul", "-Xmx256m", "-XX:+UseSerialGC", "-jar", "app.jar"]
