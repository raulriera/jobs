import Foundation
import Vapor

/// A `Service` used to dispatch `Jobs`
public struct QueueService: Service {
    
    /// See `JobsProvider`.`refreshInterval`
    let refreshInterval: TimeAmount
    
    /// See `JobsProvider`.`persistenceLayer`
    let persistenceLayer: JobsPersistenceLayer
    
    /// See `JobsProvider`.`persistenceKey`
    let persistenceKey: String
    
    /// Dispatches a job to the queue for future execution
    ///
    /// - Parameters:
    ///   - jobData: The `JobData` to dispatch to the queue
    ///   - maxRetryCount: The number of retries to attempt upon error before calling `Job`.`error()`
    ///   - queue: The queue to run this job on
    /// - Returns: A future `Void` value used to signify completion
    public func dispatch<J: JobData>(jobData: J, maxRetryCount: Int = 0, queue: QueueName = .default) throws -> EventLoopFuture<Void> {
        let data = try JSONEncoder().encode(jobData)
        let jobStorage = JobStorage(key: persistenceKey,
                                    data: data,
                                    maxRetryCount: maxRetryCount,
                                    id: UUID().uuidString,
                                    jobName: J.jobName)
        
        return persistenceLayer.set(key: queue.makeKey(with: persistenceKey), jobStorage: jobStorage).transform(to: ())
    }
}
