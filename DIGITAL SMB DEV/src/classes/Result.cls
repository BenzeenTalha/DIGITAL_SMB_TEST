public virtual class Result {
    
    final Object value;
    final String message;
    
    Result(Object obj, String message) {
        this.value = obj;
        this.message = message;
    }
    
    public static Success success(Object value) {
        return new Success(value);
    }
    
    public static Failure failure(String message) {
        return new Failure(message);
    } 
    
    public Boolean isFailure() {
        return value == null;
    }
    
    public Boolean isSuccess() {
        return value != null;
    }
    
    public String getMessage() {
        return message == null ? '' : message;
    }
    
    public Object getValue() {
        return value;
    }
    
    public class Success extends Result {
        public Success(Object value) {
            super(value, null);
        }
    }

    public class Failure extends Result {
        public Failure(String message) {
            super(null, message);
        }
    }
    
}